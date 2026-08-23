#!/bin/sh
set -eu

if [ $# -ne 2 ]; then
  echo "usage: build_adaptive_module.sh PROFILE_SET OUTPUT.zip" >&2
  exit 2
fi

ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
PROFILE_SET=$(CDPATH= cd -- "$1" && pwd)
OUTPUT=$2
mkdir -p "$(dirname "$OUTPUT")"
OUTPUT_DIR=$(CDPATH= cd -- "$(dirname "$OUTPUT")" && pwd)
OUTPUT=$OUTPUT_DIR/$(basename "$OUTPUT")
STAGE=$ROOT/out/adaptive-module-stage
APKTOOL=$ROOT/out/tools/apktool-device.jar
AAPT2=$ROOT/out/tools/aapt2-arm64-v8a
ZIPALIGN=$ROOT/out/tools/zipalign-arm64-v8a

[ -f "$PROFILE_SET/plan.conf" ] || { echo "missing plan.conf" >&2; exit 1; }
[ -f "$APKTOOL" ] && [ -f "$AAPT2" ] && [ -f "$ZIPALIGN" ] || {
  echo "missing device prebuilts under out/tools" >&2
  exit 1
}

rm -rf "$STAGE"
mkdir -p "$STAGE/tools"
cp -R "$ROOT/module-template/." "$STAGE/"
cp -R "$PROFILE_SET" "$STAGE/profile-set"
# Ship sibling version sets so customize.sh can select by the device OS.
PROFILE_ROOT=$(dirname "$PROFILE_SET")
mkdir -p "$STAGE/profile-sets"
for sibling in "$PROFILE_ROOT"/*; do
  [ -d "$sibling" ] || continue
  [ "$sibling" = "$PROFILE_SET" ] && continue
  cp -R "$sibling" "$STAGE/profile-sets/$(basename "$sibling")"
done
cp "$ROOT/tools/adaptive_patcher.sh" "$STAGE/tools/adaptive_patcher.sh"
cp "$APKTOOL" "$STAGE/tools/apktool-device.jar"
cp "$AAPT2" "$STAGE/tools/aapt2"
cp "$ZIPALIGN" "$STAGE/tools/zipalign"
chmod 0755 "$STAGE/customize.sh" "$STAGE/action.sh" "$STAGE/tools/adaptive_patcher.sh" "$STAGE/tools/aapt2" "$STAGE/tools/zipalign"

rm -f "$OUTPUT"
(cd "$STAGE" && zip -q -r -FS "$OUTPUT" .)
sha256sum "$OUTPUT"
