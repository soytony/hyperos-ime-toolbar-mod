#!/system/bin/sh

SKIPMOUNT=false
PROPFILE=true
POSTFSDATA=false
LATESTARTSERVICE=true

ui_print "- HyperOS 输入法底栏自适应补丁 / IME toolbar adaptive patcher"

TOOLS=$MODPATH/tools
SET=$MODPATH/profile-set
PATCHER=$TOOLS/adaptive_patcher.sh
APKTOOL=$TOOLS/apktool-device.jar
AAPT2=$TOOLS/aapt2
ZIPALIGN=$TOOLS/zipalign
WORK=${TMPDIR:-/data/local/tmp}/hyperos-ime-adaptive

[ -f "$SET/plan.conf" ] || abort "Missing profile-set/plan.conf"
chmod 0755 "$PATCHER" "$AAPT2" "$ZIPALIGN" || abort "Cannot set tool permissions"
mkdir -p "$WORK" "$MODPATH/reports" || abort "Cannot create working directories"
export TMPDIR=$WORK/tmp
mkdir -p "$TMPDIR" || abort "Cannot create temporary directory"

ui_print ""
ui_print "[检查 / CHECK] HyperOS 3.0+、arm64 架构 / HyperOS 3.0+ and arm64"
os_name=$(getprop ro.mi.os.version.name)
abi=$(getprop ro.product.cpu.abi)
case "$os_name" in OS3.*|OS4.*|OS5.*) ;; *) abort "需要 HyperOS 3.0+；Requires HyperOS 3.0+ (检测到 / detected: $os_name)" ;; esac
case "$abi" in arm64-v8a|arm64) ;; *) abort "需要 arm64；Requires arm64 (检测到 / detected: $abi)" ;; esac

ui_print ""
ui_print "[安全确认 / SECURITY PROMPT]"
ui_print "音量上键：执行系统 APK 签名校验 patch / VOL+: patch system APK signature proof"
ui_print "音量下键：跳过 / VOL-: skip"
ui_print "官改 EU ROM 可能已集成该 patch；修改系统 APK 而未 patch 可能无法开机。"
ui_print "EU/custom ROM may already include it; modified system APKs without this patch may boot-loop."
choice=skip
event=$(timeout 20 getevent -ql 2>/dev/null | awk '/KEY_VOLUMEUP/ {print "up"; exit} /KEY_VOLUMEDOWN/ {print "down"; exit}') || true
[ "$event" = up ] && choice=apply
[ "$event" = down ] && choice=skip
if [ "$choice" = apply ]; then
  ui_print "签名校验 patch：已选择 / Signature proof patch: selected"
  sig_profile=$SET/profiles/signature-proof
  [ -d "$sig_profile" ] || abort "缺少签名 patch profile / Missing signature profile"
  signature_profiles=$sig_profile
else
  ui_print "签名校验 patch：跳过 / Signature proof patch: skipped"
  signature_profiles=
fi

ui_print "- 检查目标文件与 profiles / Validating targets and profiles"
while IFS='|' read -r source profiles; do
  case "$source" in ''|'#'*) continue ;; esac
  [ -f "$source" ] || abort "Missing target: $source"
  [ -n "$profiles" ] || abort "No profiles configured for $source"
done < "$SET/plan.conf"

ui_print "- 应用 smali profiles（4 个文件）/ Applying profiles (4 artifacts)"
artifact_index=0
while IFS='|' read -r source profiles; do
  case "$source" in ''|'#'*) continue ;; esac
  artifact_index=$((artifact_index + 1))
  if [ "$source" = /system/framework/services.jar ] && [ -n "$signature_profiles" ]; then
    profiles=signature-proof,$profiles
  fi
  artifact_work=$WORK/artifact-$artifact_index
  mkdir -p "$artifact_work" || abort "Cannot create artifact work directory"
  case "$source" in *.jar) archive_suffix=jar ;; *) archive_suffix=apk ;; esac
  output=$artifact_work/result.$archive_suffix
  profile_total=$(printf '%s' "$profiles" | awk -F, '{print NF}')
  ui_print ""
  ui_print "[$artifact_index/4] $(basename "$source")"
  ui_print "  目标已确认；profiles: $profile_total / Target verified; profiles: $profile_total"
  old_ifs=$IFS
  IFS=','
  profile_dirs=
  for profile_name in $profiles; do
    [ -z "$profile_dirs" ] && profile_dirs=$SET/profiles/$profile_name || \
      profile_dirs=$profile_dirs,$SET/profiles/$profile_name
  done
  IFS=$old_ifs
  if ! "$PATCHER" patch --device --artifact "$source" --profiles "$profile_dirs" \
      --workdir "$artifact_work/work" --apktool "$APKTOOL" \
      --aapt2 "$AAPT2" --zipalign "$ZIPALIGN" --output "$output"; then
    ui_print "[错误 / ERROR] Patch 失败 / Failed: $(basename "$source")"
    ui_print "        日志 / Log: $artifact_work/work/tool.log"
    abort "Adaptive patch failed at artifact $artifact_index/4"
  fi
  cp "$artifact_work/work/patch-report.txt" "$MODPATH/reports/$artifact_index.txt" || \
    abort "Cannot save report for artifact $artifact_index"

  relative=${source#/}
  destination=$MODPATH/$relative
  mkdir -p "$(dirname "$destination")" || abort "Cannot create overlay directory"
  cp "$output" "$destination" || abort "Cannot stage patched $(basename "$source")"
  chmod 0644 "$destination" || abort "Cannot set payload permissions"
done < "$SET/plan.conf"

set_perm_recursive "$MODPATH" 0 0 0755 0644 u:object_r:system_file:s0
set_perm "$PATCHER" 0 0 0755 u:object_r:system_file:s0
set_perm "$AAPT2" 0 0 0755 u:object_r:system_file:s0
set_perm "$ZIPALIGN" 0 0 0755 u:object_r:system_file:s0
set_perm "$MODPATH/service.sh" 0 0 0755 u:object_r:system_file:s0
ui_print ""
ui_print "[成功 / SUCCESS] 自适应 patch 完成 / Adaptive patch completed"
