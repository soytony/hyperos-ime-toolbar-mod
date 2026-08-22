#!/system/bin/sh
set -eu

usage() {
  echo "Usage:" >&2
  echo "  adaptive_patcher.sh inspect --artifact FILE --profile DIR --workdir DIR --apktool FILE [--device]" >&2
  echo "  adaptive_patcher.sh patch --artifact FILE --profiles DIR[,DIR...] --workdir DIR --apktool FILE --aapt2 FILE --zipalign FILE --output FILE [--device]" >&2
  exit 2
}

die() { echo "adaptive-patcher 错误 / ERROR: $*" >&2; exit 1; }
fail_with_log() {
  message=$1
  echo "[错误/ERROR] $message" >&2
  if [ -s "$tool_log" ]; then
    echo "[详细日志/DETAILS] $tool_log" >&2
    tail -80 "$tool_log" >&2
  fi
  exit 1
}
progress() {
  case "$1" in
    1/6) cn='解码 APK/JAR' ;;
    2/6) cn='应用 smali profiles' ;;
    3/6) cn='重新构建临时 DEX' ;;
    4/6) cn='写回目标 DEX' ;;
    5/6) cn='执行 zipalign' ;;
    6/6) cn='验证 DEX 和 ZIP 条目' ;;
    PATCH) cn='检查并替换目标函数' ;;
    DEX) cn='目标 DEX' ;;
    DONE) cn='完成' ;;
    *) cn='处理' ;;
  esac
  printf '[%s] %s / %s\n' "$1" "$cn" "$2"
}

mode=${1-}
[ $# -gt 0 ] && shift || true
artifact=
profile=
profiles=
workdir=
apktool=
aapt2=
zipalign=
output=
device=0

while [ $# -gt 0 ]; do
  case "$1" in
    --artifact) artifact=${2-}; shift 2 ;;
    --profile) profile=${2-}; shift 2 ;;
    --profiles) profiles=${2-}; shift 2 ;;
    --workdir) workdir=${2-}; shift 2 ;;
    --apktool) apktool=${2-}; shift 2 ;;
    --aapt2) aapt2=${2-}; shift 2 ;;
    --zipalign) zipalign=${2-}; shift 2 ;;
    --output) output=${2-}; shift 2 ;;
    --device) device=1; shift ;;
    *) usage ;;
  esac
done

[ -n "$mode" ] && [ -n "$artifact" ] && [ -n "$workdir" ] || usage
[ -n "$profiles" ] || profiles=$profile
[ -n "$profiles" ] || usage
[ -f "$artifact" ] || die "artifact does not exist: $artifact"
[ -f "$apktool" ] || die "missing apktool jar: $apktool"

get_profile() {
  profile_dir=$1
  profile_key=$2
  profile_value=$(awk -F= -v key="$profile_key" '$1 == key {sub(/^[[:space:]]*/, "", $2); print $2; exit}' "$profile_dir/profile.conf")
  [ -n "$profile_value" ] || die "profile key is missing: $profile_key"
  printf '%s' "$profile_value"
}

apktool_run() {
  if [ "$device" = 1 ]; then
    dalvikvm -Duser.home="$workdir/home" -cp "$apktool" io.github.soytony.dexpatchhelper.DeviceApktoolMain "$@"
  else
    java -jar "$apktool" "$@"
  fi
}

java_helper() {
  helper_class=$1
  shift
  if [ "$device" = 1 ]; then
    dalvikvm -cp "$apktool" "$helper_class" "$@"
  else
    java -cp "$apktool" "$helper_class" "$@"
  fi
}

mkdir -p "$workdir"
workdir=$(CDPATH= cd -- "$workdir" && pwd)
mkdir -p "$workdir/home"
decode_dir=$workdir/decoded
rebuild_file=$workdir/rebuilt.apk
tool_log=$workdir/tool.log
rm -rf "$decode_dir" "$rebuild_file" "$workdir/archive.apk" "$workdir/aligned.apk" "$workdir/patch-report.txt"
: > "$tool_log"

progress '1/6' "Decoding $(basename "$artifact")"
case "$artifact" in
  *.apk) decode_args="d --no-res -j 1 -f $artifact -o $decode_dir" ;;
  *) decode_args="d -j 1 -f $artifact -o $decode_dir" ;;
esac
if ! apktool_run $decode_args >> "$tool_log" 2>&1; then
  tail -40 "$tool_log" >&2
  die "decode failed; full log: $tool_log"
fi

old_ifs=$IFS
IFS=','
profile_count=0
target_dexes=
progress '2/6' 'Applying smali profiles'
for profile_dir in $profiles; do
  profile_count=$((profile_count + 1))
  [ -f "$profile_dir/profile.conf" ] || die "missing profile.conf: $profile_dir"
  class_name=$(get_profile "$profile_dir" class)
  method_sig=$(get_profile "$profile_dir" method)
  operation=$(get_profile "$profile_dir" operation)
  expected=$(get_profile "$profile_dir" expected_matches)
  case "$expected" in
    all) : ;;
    ''|*[!0-9]*) die "profile $profile_dir has invalid expected_matches='$expected' (use a non-negative integer or all)" ;;
  esac
  if [ "$operation" = replace-method-result-all ]; then
    anchor=$(get_profile "$profile_dir" anchor)
    class_file=$(grep -rlF "$anchor" "$decode_dir" --include='*.smali' 2>/dev/null | sed -n '1p')
  else
    class_file=$(find "$decode_dir" -type f -name "$(basename "$class_name").smali" -path "*${class_name%/*}/*" -print -quit 2>/dev/null)
  fi
  [ -n "$class_file" ] || die "profile $profile_dir: target anchor/class not found ($class_name, $method_sig)"
  class_relative=${class_file#"$decode_dir"/}
  smali_dir=${class_relative%%/*}
  case "$smali_dir" in
    smali) target_dex=classes.dex ;;
    smali_classes[0-9]*) target_dex=classes${smali_dir#smali_classes}.dex ;;
    *) die "cannot map smali directory to DEX: $smali_dir" ;;
  esac
  case ",$target_dexes," in
    *,$target_dex,*) ;;
    *) target_dexes=${target_dexes:+$target_dexes,}$target_dex ;;
  esac
  if [ "$operation" = replace-method-result-all ]; then
    anchor_count=0
    candidate_list=$workdir/candidates.txt
    find "$decode_dir" -type f -name '*.smali' -print > "$candidate_list"
    while IFS= read -r candidate; do
      count=$(grep -Fo "$anchor" "$candidate" 2>/dev/null | wc -l | tr -d ' ')
      anchor_count=$((anchor_count + count))
    done < "$candidate_list"
    method_count=$anchor_count
    if [ "$expected" != all ] && [ "$method_count" -ne "$expected" ]; then
      die "profile $profile_dir operation $operation: found $method_count anchor invocation(s), expected exactly $expected"
    fi
    [ "$method_count" -gt 0 ] || die "profile $profile_dir operation $operation: no anchor invocations found"
  else
    method_count=$(awk -v sig="$method_sig" '$0 ~ "^\\.method " && substr($0, length($0)-length(sig), length(sig)+1) == " " sig { count++ } END { print count + 0 }' "$class_file")
    [ "$expected" != all ] || die "profile $profile_dir method $method_sig: expected_matches=all is only supported by all-occurrence operations"
    [ "$method_count" = "$expected" ] || die "profile $profile_dir method $method_sig: found $method_count method(s), expected exactly $expected"
  fi
  progress 'PATCH' "$(basename "$profile_dir"): $class_name->$method_sig"

  if [ "$mode" = inspect ]; then
    printf 'profile=%s\nartifact=%s\nsha256=%s\nclass=%s\nmethod=%s\nmatches=%s\n' \
      "$profile_dir" "$artifact" "$source_hash" "$class_name" "$method_sig" "$method_count"
    continue
  fi
  [ "$mode" = patch ] || usage
  case "$operation" in
    replace-method)
      [ -s "$profile_dir/replacement.smali" ] || die "missing replacement.smali"
      java_helper io.github.soytony.dexpatchhelper.SmaliTextPatcher replace-method "$class_file" "$method_sig" "$profile_dir/replacement.smali" >> "$tool_log" 2>&1 || fail_with_log "profile=$profile_dir file=$class_relative operation=$operation failed"
      ;;
    replace-text)
      [ -s "$profile_dir/old.smali" ] && [ -f "$profile_dir/new.smali" ] || die "missing old.smali or new.smali"
      java_helper io.github.soytony.dexpatchhelper.SmaliTextPatcher replace-text "$class_file" "$profile_dir/old.smali" "$profile_dir/new.smali" >> "$tool_log" 2>&1 || fail_with_log "profile=$profile_dir file=$class_relative operation=$operation failed"
      ;;
    insert-before-method)
      [ -s "$profile_dir/insertion.smali" ] || die "missing insertion.smali"
      java_helper io.github.soytony.dexpatchhelper.SmaliTextPatcher insert-before-method "$class_file" "$method_sig" "$profile_dir/insertion.smali" >> "$tool_log" 2>&1 || fail_with_log "profile=$profile_dir file=$class_relative operation=$operation failed"
      ;;
    replace-method-result)
      anchor=$(get_profile "$profile_dir" anchor)
      return_type=$(get_profile "$profile_dir" return_type)
      value=$(get_profile "$profile_dir" value)
      java_helper io.github.soytony.dexpatchhelper.SmaliTextPatcher replace-method-result "$class_file" "$anchor" "$return_type" "$value" >> "$tool_log" 2>&1 || fail_with_log "profile=$profile_dir file=$class_relative operation=$operation failed"
      ;;
    replace-method-result-all)
      anchor=$(get_profile "$profile_dir" anchor)
      return_type=$(get_profile "$profile_dir" return_type)
      value=$(get_profile "$profile_dir" value)
      candidate_list=$workdir/candidates.txt
      find "$decode_dir" -type f -name '*.smali' -print > "$candidate_list"
      while IFS= read -r candidate; do
        if grep -Fq "$anchor" "$candidate"; then
          candidate_relative=${candidate#"$decode_dir"/}
          java_helper io.github.soytony.dexpatchhelper.SmaliTextPatcher replace-method-result "$candidate" "$anchor" "$return_type" "$value" >> "$tool_log" 2>&1 || fail_with_log "profile=$profile_dir file=$candidate_relative operation=$operation failed"
          rel=${candidate#"$decode_dir"/}; dir=${rel%%/*}
          case "$dir" in smali) d=classes.dex ;; smali_classes[0-9]*) d=classes${dir#smali_classes}.dex ;; esac
          case ",$target_dexes," in *,$d,*) ;; *) target_dexes=${target_dexes:+$target_dexes,}$d ;; esac
        fi
      done < "$candidate_list"
      ;;
    *) die "unsupported operation: $operation" ;;
  esac
done
IFS=$old_ifs
[ "$mode" = inspect ] && exit 0
[ "$profile_count" -gt 0 ] || die "no profiles specified"
[ -n "$target_dexes" ] || die "no target DEX was selected"
[ -f "$aapt2" ] && [ -f "$zipalign" ] && [ -n "$output" ] || usage
chmod 0755 "$aapt2" "$zipalign"

progress 'DEX' "Target DEX: $target_dexes"
progress '3/6' 'Rebuilding temporary DEX source'
if ! apktool_run b -j 1 -f --aapt "$aapt2" "$decode_dir" -o "$rebuild_file" >> "$tool_log" 2>&1; then
  tail -40 "$tool_log" >&2
  die "rebuild failed; full log: $tool_log"
fi
progress '4/6' 'Injecting rebuilt classes*.dex into original archive'
java_helper io.github.soytony.dexpatchhelper.DexArchiveInjector "$artifact" "$rebuild_file" "$workdir/archive.apk" "$target_dexes" >> "$tool_log" 2>&1 || fail_with_log "DEX injection failed for $(basename "$artifact")"
mkdir -p "$(dirname "$output")"
progress '5/6' 'Aligning output archive'
"$zipalign" -f 4 "$workdir/archive.apk" "$output" >> "$tool_log" 2>&1 || fail_with_log "zipalign failed for $(basename "$artifact")"
"$zipalign" -c 4 "$output" >> "$tool_log" 2>&1 || fail_with_log "zipalign verification failed: $output"
progress '6/6' 'Verifying DEX and preserved non-DEX entries'
java_helper io.github.soytony.dexpatchhelper.ArchiveVerifier "$artifact" "$output" "$target_dexes" >> "$tool_log" 2>&1 || fail_with_log "archive verification failed for $(basename "$artifact")"

output_hash=$(sha256sum "$output" | awk '{print $1}')
printf 'artifact=%s\noutput_sha256=%s\nprofiles=%s\nprofile_count=%s\ntarget_dexes=%s\n' \
  "$artifact" "$output_hash" "$profiles" "$profile_count" "$target_dexes" > "$workdir/patch-report.txt"
cat "$workdir/patch-report.txt"
progress 'DONE' "Patched $(basename "$artifact") with $profile_count profile(s)"
