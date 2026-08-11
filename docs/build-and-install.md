# Build And Install

## Prerequisites

- Java, `javac`, D8/R8, `zip`, and `unzip` on the host.
- apktool 3.x JAR, arm64 `aapt2`, and arm64 `zipalign` in `out/tools/`.
- A rooted HyperOS 3.0+ arm64 device with KernelSU.

Build the device helper and module:

```sh
sh tools/build_device_apktool.sh
sh tools/build_adaptive_module.sh \
  profile-sets/hyperos3-arm64-3.0 \
  out/hyperos-ime-toolbar-adaptive.zip
```

The builder copies only the template, profile set, patcher, helper JAR, and
required binaries into the ZIP. It does not embed device APK/JAR payloads.

## Install

```sh
adb -s SERIAL push out/hyperos-ime-toolbar-adaptive.zip /sdcard/Download/
```

Install the ZIP from KernelSU. During installation, read the bilingual warning
and use volume up to enable signature-proof patching or volume down to skip it.
Reboot after installation. Never manually replace or resign the target APK/JAR.

## Verify

1. Confirm the module is enabled and its installer report contains four target
   archives.
2. Use UIAutomator to confirm the `com.miui.phrase` toolbar window exists.
3. Test Gboard, WeChat Input Method, keyboard cycling, and language cycling.
4. Inspect `logcat -b crash` for regressions.
5. For color changes, validate the visible IME frame with
   `tools/analyze_ime_colors.py` after locating it using `dumpsys window`.

If the device boot-loops, disable the module from KernelSU safe mode before
attempting another profile or signature-proof choice.
