# Build And Install

## Prerequisites

- A JDK providing `java` and `javac`, plus `jar`, `zip`, and `unzip`.
- apktool 3.0.3 at `out/tools/apktool_3.0.3.jar`.
- An R8 JAR containing `com.android.tools.r8.D8`. By default,
  `tools/build_device_apktool.sh` uses
  `/home/tony/android/lineage/prebuilts/r8/r8.jar`; set `R8_JAR` to override it.
- Device bundle artifacts named exactly `out/tools/apktool-device.jar`,
  `out/tools/aapt2-arm64-v8a`, and `out/tools/zipalign-arm64-v8a`.
- A rooted arm64 device with KernelSU and a tested recovery/safe-mode path.
  HyperOS `OS3.*` is the validated path. Other reported versions require an
  explicit installation-time confirmation and must be tested by the user.

Build the device helper first; it packages apktool, repository helper classes,
and D8-generated Android-compatible DEX. Target framework/application smali is
patched directly and is never converted to Java. Then build the module:

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

Install the ZIP from KernelSU. On a system other than HyperOS `OS3.*`, the
installer first warns that the profile set is unvalidated; volume up continues,
while volume down or no input in 20 seconds cancels installation. It then asks
whether to enable signature-proof patching: volume up enables it, and volume
down or no input in 20 seconds skips it. Reboot after installation. Never
manually replace or resign the target APK/JAR.

After installation, the module's action button in the KernelSU module list
opens the Settings fragment containing `全面屏键盘优化`.

## Verify

1. Confirm the module is enabled and its installer report contains the current
   profile set's four target archives: `Settings.apk`, `miui-framework.jar`,
   `services.jar`, and the APK resolved from package `com.miui.phrase`.
2. Use `dumpsys input_method` to confirm that the active IME is shown, then use
   `dumpsys window` to locate the `InputMethod` window and its bounds. The
   toolbar is embedded in the active IME window/process; it is not necessarily
   exposed as a standalone `com.miui.phrase` window.
3. Use UIAutomator to locate the focused editable field and any toolbar controls
   exposed in the accessibility hierarchy. Use screenshots only for visual or
   color validation when the toolbar internals are not exposed.
4. Test Gboard and WeChat Input Method: input-method selection, keyboard
   cycling, cross-IME language/subtype cycling with exact `voice` filtering,
   default voice input, clipboard/frequent phrases, and dynamic colors.
5. Assign each supported shortcut to both toolbar positions and manually
   confirm keyboard-tap haptic feedback with system touch feedback enabled.
6. Inspect `logcat -b crash` for regressions.
7. For color changes, crop the `InputMethod` region found through UIAutomator
   and `dumpsys window`, then inspect its ROI with
   `tools/analyze_ime_colors.py` or an equivalent OpenCV script.

If the device boot-loops, disable the module from KernelSU safe mode before
attempting another profile or signature-proof choice.
