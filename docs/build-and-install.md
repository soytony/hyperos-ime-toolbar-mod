# Build And Install

## Preconditions

- `apktool`, `zip`, `unzip`, `adb`, and a working KernelSU installation.
- Original target files extracted from the exact device build.
- A device environment that accepts the modified system artifacts while
  retaining their original certificate entries.

Never use a rebuilt APK as the final payload directly. Rebuilding changes the
archive and discards the original signature files. Instead, extract its dex
and update a copy of the original archive.

## Rebuild and inject dex

```sh
apktool b decoded/MiuiFrequentPhrase -o out/MiuiFrequentPhrase-rebuilt.apk
unzip -o out/MiuiFrequentPhrase-rebuilt.apk classes.dex -d out/inject-phrase
cp apks/MiuiFrequentPhrase.apk module/product/app/MiuiFrequentPhrase/MiuiFrequentPhrase.apk
(cd out/inject-phrase && \
  zip -j ../../module/product/app/MiuiFrequentPhrase/MiuiFrequentPhrase.apk classes.dex)

apktool b decoded/services -o out/services-rebuilt.jar
unzip -o out/services-rebuilt.jar 'classes*.dex' -d out/inject-services
(cd out/inject-services && \
  zip -j ../../module/system/framework/services.jar classes*.dex)
```

Do not add `-FS` while updating an APK/JAR with dex files. It can prune
unmatched entries and remove resources. `-FS` is appropriate only when making
the outer flashable module ZIP from the complete module directory.

## Verify preserved entries

```sh
unzip -p apks/MiuiFrequentPhrase.apk META-INF/CERT.RSA | sha256sum
unzip -p module/product/app/MiuiFrequentPhrase/MiuiFrequentPhrase.apk META-INF/CERT.RSA | sha256sum
unzip -p apks/MiuiFrequentPhrase.apk META-INF/MANIFEST.MF | sha256sum
unzip -p module/product/app/MiuiFrequentPhrase/MiuiFrequentPhrase.apk META-INF/MANIFEST.MF | sha256sum
```

The corresponding pairs must match.

## Package and install

```sh
(cd module && zip -r -FS ../out/hyperos-ime-bottom-universal-vX.Y.Z.zip .)
adb -s SERIAL push out/hyperos-ime-bottom-universal-vX.Y.Z.zip /data/local/tmp/ime-mod.zip
adb -s SERIAL shell "su -c '/data/adb/ksu/bin/ksud module install /data/local/tmp/ime-mod.zip'"
adb -s SERIAL reboot
```

## Verification

1. Check the module version after reboot.
2. Set WeChat Input Method as current and use the toolbar picker to select
   Gboard. Confirm Gboard becomes current and WeChat does not crash.
3. Set the toolbar action to cycle keyboard. Confirm repeated presses traverse
   every enabled IME and wrap at the end.
4. Enable at least two languages in an IME, set the action to switch language,
   and confirm it advances subtypes, then enters the next enabled IME after
   the last subtype.
5. Use `uiautomator dump` before screenshots for UI-state inspection.
6. Inspect `logcat -b crash` for new Java crashes.
