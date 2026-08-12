# HyperOS IME Toolbar Adaptive Module

This repository builds a KernelSU module that restores the HyperOS IME bottom
toolbar and adapts its IME selection, keyboard-cycle, language-cycle, and
dynamic-color behavior.

## Features / 功能特性

### 任意输入法 / Any enabled IME

The toolbar is enabled for any input method that Android reports as enabled,
including third-party IMEs such as Gboard and WeChat Input Method. Xiaomi's
original package allowlist and visibility filtering are bypassed through
targeted framework patches. The module does not require the IME to be signed
with the ROM's platform certificate.

### 跨输入法语言轮换 / Cross-IME language cycling

The “switch language” action walks one circular sequence of enabled
`(input-method, subtype)` pairs. It advances to the next language inside the
current IME, then continues with the first language of the next enabled IME;
after the final IME it wraps back to the first pair. IMEs without exposed
subtypes still participate using their default subtype. Subtypes whose mode is
exactly `voice` are excluded from this action so voice input remains available
through its dedicated toolbar button; handwriting and vendor-defined subtype
modes remain eligible.

### 剪贴板和常用语 / Clipboard and frequent phrases

The toolbar's clipboard and frequent-phrase panel works with any enabled IME.
Copied content continues to be collected by Xiaomi's existing clipboard
manager; a targeted provider-access profile only removes the original IME
package allowlist that otherwise prevents a third-party IME from reading that
already-recorded history.

### 系统默认语音输入 / System default voice input

The toolbar's voice-input action delegates target selection to
`system_server`. The IME-side toolbar sends a module-private sentinel instead
of reading restricted secure settings or guessing the first installed voice
IME. `system_server` resolves that sentinel with
`InputMethodSettings.getDefaultVoiceInputMethod()` and switches to the exact
voice IME configured for the current user.

The framework exception is narrowly scoped: the resolved default voice IME
may be selected even when it is not present in the ordinary enabled-IME list.
Other disabled or unknown IMEs remain rejected. This behavior has been
manually verified from both Gboard and WeChat Input Method on the tested
device.

### 自动动态取色 / Automatic dynamic color sampling

When the toolbar is attached or its layout/settings change, the patch samples
the current IME's rendered input frame and derives an opaque toolbar color.
Toolbar and shortcut-button backgrounds update immediately, with contrasting
normal/pressed colors selected for readability. Sampling is event-driven and
does not continuously capture the screen or require screenshot permission.

### 按钮触觉反馈 / Shortcut haptic feedback

Both toolbar shortcut buttons provide a keyboard-tap haptic response when
pressed, regardless of which side or supported action is assigned. This covers
input-method switching, keyboard cycling, language cycling, voice input, and
the clipboard/frequent-phrase panel. The implementation uses Android view
haptic feedback, requires no `VIBRATE` permission, and follows the user's
system haptic-feedback setting.

The module is installation-time adaptive: it decodes each device's mounted
APK/JAR with apktool, locates configured classes and methods by signature,
patches smali, rebuilds only the changed DEX entries, and preserves all
non-DEX archive entries including existing certificates. It never resigns
system packages and does not identify a device by product name or whole-file
hash.

## Repository layout

- `module-template/`: KernelSU installer, runtime property, and service files.
- `profile-sets/hyperos3-arm64-3.0/`: current generic HyperOS 3.0+ arm64
  profiles and target paths.
- `tools/adaptive_patcher.sh`: device/host patch orchestration.
- `tools/device-java/`: apktool wrapper, smali patcher, DEX injector, and
  archive verifier.
- `tools/build_adaptive_module.sh`: reproducible module ZIP builder.
- `tools/build_device_apktool.sh`: builds the device-side apktool helper JAR.
- `tools/analyze_ime_colors.py`: optional color-validation utility.
- `docs/`: architecture, design, compatibility, and installation notes.
- `out/`: ignored build products and diagnostics.

## Build

Required local inputs are the pinned apktool JAR, arm64 `aapt2`, arm64
`zipalign`, and a Java/D8 toolchain. Place the device binaries under
`out/tools/`, then run:

```sh
sh tools/build_device_apktool.sh
sh tools/build_adaptive_module.sh \
  profile-sets/hyperos3-arm64-3.0 \
  out/hyperos-ime-toolbar-adaptive.zip
```

The resulting ZIP is a development artifact until it has been installed and
manually validated on the target ROM.

## Installation safety

### 已测试环境 / Tested environment

This project has been tested only on the following environment:

- Device: POCO 2510DPC44G
- System: HyperOS `OS3.0.307.0.WPKCNXM`
- Android: Android 16 / SDK 36
- Architecture: arm64-v8a

Other device models, regional ROM variants, and HyperOS releases have not been
validated unless explicitly documented. Users must test compatibility on
their own devices and be prepared to recover the system before installation.

The installer rejects non-HyperOS 3.0+ and non-arm64 devices. Before patching,
it asks with the volume keys whether to apply the optional system APK
signature-proof patch. EU/custom ROMs may already contain that modification.
Changing system APKs without the required signature behavior can cause a boot
loop; keep KernelSU safe mode available.

If the device boot-loops, use KernelSU safe mode to disable or remove this
module before rebooting normally. Confirm that safe-mode recovery is available
for the device before installation.

### 免责声明 / Disclaimer

Installing this module modifies privileged system code and may cause boot
failure, data loss, or other unexpected behavior. Use it entirely at your own
risk. This repository and its owner provide no warranty and accept no
responsibility or liability for device damage, data loss, downtime, or any
other consequences resulting from use of this project.

No commit should be made for a device build until the toolbar is confirmed
manually after reboot.
