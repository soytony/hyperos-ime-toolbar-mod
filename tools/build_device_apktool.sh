#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
APKTOOL=${APKTOOL:-$ROOT/out/tools/apktool_3.0.3.jar}
R8_JAR=${R8_JAR:-/home/tony/android/lineage/prebuilts/r8/r8.jar}
OUT=${OUT:-$ROOT/out/tools/apktool-device.jar}
BUILD=$ROOT/out/device-java-build

rm -rf "$BUILD"
mkdir -p "$BUILD/classes" "$BUILD/dex"
javac --release 8 -cp "$APKTOOL" -d "$BUILD/classes" \
  "$ROOT"/tools/device-java/src/io/github/hyperosime/*.java
jar cf "$BUILD/helper.jar" -C "$BUILD/classes" .
java -cp "$R8_JAR" com.android.tools.r8.D8 --min-api 26 \
  --output "$BUILD/dex" "$APKTOOL" "$BUILD/helper.jar"
cp "$APKTOOL" "$OUT"
(cd "$BUILD/classes" && jar uf "$OUT" io/github/hyperosime)
(cd "$BUILD/dex" && zip -q -0 "$OUT" classes.dex)
sha256sum "$OUT"
