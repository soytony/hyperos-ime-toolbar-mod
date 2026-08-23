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
ui_print "[检查 / CHECK] 系统版本与 arm64 架构 / System version and arm64 ABI"
os_name=$(getprop ro.mi.os.version.name)
abi=$(getprop ro.product.cpu.abi)
case "$abi" in arm64-v8a|arm64) ;; *) abort "需要 arm64；Requires arm64 (检测到 / detected: $abi)" ;; esac

case "$os_name" in
  OS3.*)
    [ -d "$MODPATH/profile-sets/hyperos3-arm64-3.0" ] && SET=$MODPATH/profile-sets/hyperos3-arm64-3.0
    ui_print "HyperOS 3 已检测到 / HyperOS 3 detected: $os_name"
    ;;
  OS4.*)
    if [ -d "$MODPATH/profile-sets/hyperos4-arm64-4.0" ]; then
      SET=$MODPATH/profile-sets/hyperos4-arm64-4.0
      ui_print ""
      ui_print "[警告 / WARNING] HyperOS 4 profile-set 为实验版本 / experimental"
      ui_print "该 profile-set 已包含 HyperOS 4 的 IME toolbar 目标，但仍属实验版本。"
      ui_print "This set includes HyperOS 4 IME toolbar targets but remains experimental."
      ui_print "音量上键：继续实验性安装 / VOL+: continue experimental installation"
      ui_print "音量下键或 20 秒无输入：退出 / VOL- or no input in 20s: abort"
      version_event=$(timeout 20 getevent -ql 2>/dev/null | awk '/KEY_VOLUMEUP/ {print "up"; exit} /KEY_VOLUMEDOWN/ {print "down"; exit}') || true
      [ "$version_event" = up ] || abort "已取消 HyperOS 4 实验安装 / HyperOS 4 experimental installation cancelled"
      ui_print "HyperOS 4 profile-set selected / 已选择 HyperOS 4 profile-set"
    fi
    ;;
  *)
    ui_print ""
    ui_print "[警告 / WARNING] 未检测到 HyperOS 3 / HyperOS 3 not detected"
    ui_print "检测到 / Detected: ${os_name:-unknown}"
    ui_print "对应版本 profile-set 未完成验证；方法签名不匹配时会中止，但仍可能存在风险。"
    ui_print "The version profile-set is not fully validated; signature mismatches abort, but risk remains."
    ui_print "音量上键：继续尝试安装 / VOL+: continue installation attempt"
    ui_print "音量下键或 20 秒无输入：退出 / VOL- or no input in 20s: abort"
    version_event=$(timeout 20 getevent -ql 2>/dev/null | awk '/KEY_VOLUMEUP/ {print "up"; exit} /KEY_VOLUMEDOWN/ {print "down"; exit}') || true
    [ "$version_event" = up ] || abort "已取消非 HyperOS 3 安装 / Non-HyperOS-3 installation cancelled"
    ui_print "已确认继续 / Continue confirmed"
    ;;
esac

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
  if [ -d "$SET/profiles/signature-proof-session" ]; then
    signature_profiles=$signature_profiles,$SET/profiles/signature-proof-session
  fi
else
  ui_print "签名校验 patch：跳过 / Signature proof patch: skipped"
  signature_profiles=
fi

ui_print "- 检查目标文件与 profiles / Validating targets and profiles"
resolve_source() {
  source_spec=$1
  case "$source_spec" in
    @package:*)
      package=${source_spec#@package:}
      resolved=$(pm path "$package" 2>/dev/null | sed -n 's/^package://p' | awk '/\.apk$/ {print; exit}')
      [ -n "$resolved" ] || abort "找不到 package / Package not found: $package"
      [ -f "$resolved" ] || abort "APK 路径不存在 / APK path missing: $resolved"
      printf '%s' "$resolved"
      ;;
    *) printf '%s' "$source_spec" ;;
  esac
}
while IFS='|' read -r source profiles; do
  case "$source" in ''|'#'*) continue ;; esac
  source=$(resolve_source "$source")
  [ -f "$source" ] || abort "Missing target: $source"
  [ -n "$profiles" ] || abort "No profiles configured for $source"
done < "$SET/plan.conf"

artifact_total=$(awk -F'|' '$1 !~ /^($|#)/ {count++} END {print count + 0}' "$SET/plan.conf")
ui_print "- 应用 smali profiles（${artifact_total} 个文件）/ Applying profiles (${artifact_total} artifacts)"
artifact_index=0
while IFS='|' read -r source profiles; do
  case "$source" in ''|'#'*) continue ;; esac
  source=$(resolve_source "$source")
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
  ui_print "[$artifact_index/$artifact_total] $(basename "$source")"
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
    if [ -s "$artifact_work/work/tool.log" ]; then
      ui_print "        最近错误 / Recent details:"
      tail -20 "$artifact_work/work/tool.log" | while IFS= read -r line; do
        ui_print "          $line"
      done
    fi
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
set_perm "$MODPATH/action.sh" 0 0 0755 u:object_r:system_file:s0
ui_print ""
ui_print "[成功 / SUCCESS] 自适应 patch 完成 / Adaptive patch completed"
