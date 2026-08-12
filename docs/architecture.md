# Architecture

## Install-time pipeline

```text
KernelSU customize.sh
  -> validate recognized HyperOS major (OS3/OS4/OS5) and arm64
  -> volume-key choice for signature-proof patch
  -> validate target paths
  -> apktool decode
  -> match profiles by class/method signature and local anchors
  -> rebuild decoded DEX
  -> inject only changed classes*.dex into original archive
  -> zipalign and verify non-DEX entries
  -> stage overlay with 0644 payload / 0755 tools
```

The profile set is generic by design. It contains no product name, build
fingerprint, or whole APK/JAR digest. A profile fails closed when a class or
method is absent or ambiguous.

## Target archives

- `Settings.apk`: enables the IME bottom-support path.
- `miui-framework.jar`: enables support from `InputMethodServiceInjector`.
- `services.jar`: exposes the complete enabled-IME list, removes the
  `supportsSwitchingToNextInputMethod()` capability filter, routes direct and
  next-IME switches through switching-aware rotation logic, and updates user
  action/recency state. It also resolves the toolbar's private voice sentinel
  to the current user's system default voice IME and narrowly permits that
  exact target when it is absent from the ordinary enabled list.
- `MiuiFrequentPhrase.apk`: creates and exposes the toolbar for any enabled
  IME, removes package/provider allowlists, exposes enabled IMEs to the toolbar,
  cycles IMEs, traverses subtypes across IMEs, routes voice and clipboard
  actions, samples dynamic colors, and provides haptic feedback for all five
  shortcut actions.

## Matching rules

Whole-method replacement requires the complete smali method signature:
class descriptor, method name, parameter descriptors, and return descriptor.
The implementation must occur exactly once in the decoded tree.

Instruction-level patches additionally require a bounded local sequence. The
optional signature-proof profile searches `services.jar` for
`getMinimumSignatureSchemeVersionForTargetSdk(I)I`, verifies the following
`move-result vN`, and resets that same register to zero. Only DEX files that
contain a match are selected for replacement.

## Archive preservation

`DexArchiveInjector` copies the original archive and substitutes selected
`classes*.dex` entries only. `ArchiveVerifier` requires every non-DEX entry to
retain its name, size, and CRC; this includes `META-INF/CERT.*`. `zipalign`
rewrites ZIP layout but does not resign the package.

## Clipboard provider access

`MiuiClipboardManager` retains responsibility for observing and persisting
clipboard entries. The `phrase-provider-allowlist` profile replaces only
`InputProvider.c()Z`, the provider's caller-package allowlist predicate, with
an allow result. This lets the toolbar process running under an enabled
third-party IME read its existing clipboard and frequent-phrase history. It
does not alter clipboard data, listener registration, or the UI query logic.

## Default voice IME routing

The toolbar code in `MiuiFrequentPhrase.apk` cannot safely read the hidden
`default_voice_input_method` secure setting because it executes inside the
active third-party IME process and therefore uses that IME's UID. It sends the
private ID `#hyperos-ime-toolbar:default-voice` through the existing
`InputMethodService.switchInputMethod()` path instead.

`services-switch-target` resolves this sentinel at the start of
`setInputMethodAndSubtypeLocked()` by calling
`InputMethodSettings.getDefaultVoiceInputMethod()` for the target user. This
must happen before the method-map lookup, which rejects unknown IDs. The
resolved real IME ID then follows the normal switch path.

Voice-only IMEs may be absent from Android's ordinary enabled-IME list. The
`services-voice-target` profile preserves the normal enabled check and adds
one exception: a requested ID is also accepted when it exactly equals the
system default voice IME. All other disabled or unknown IDs remain rejected.

## Runtime behavior

`system.prop` enables the HyperOS bottom view and `service.sh` sets the secure
enable flag after boot. Keyboard cycling reads the enabled IME list, finds the
current entry from `default_input_method`, selects the next entry with
wraparound, and calls `InputMethodService.switchInputMethod(nextId)`. It does
nothing when fewer than two IMEs are enabled.

Toolbar color sampling runs on attachment, layout changes, and toolbar
function/settings changes. When `mInputFrame` has valid dimensions, the helper
renders the complete frame into an ARGB bitmap and samples the pixel at its
horizontal center and `height - 5`. If rendering is unavailable, it tries
`ColorDrawable` backgrounds in this order: input frame, root view, then IME
window decor. Samples with alpha below `0xc0` are rejected. The selected
background is made opaque, black or white icon colors are chosen using an RGB
sum threshold of `0x180`, and `setBottomColor(true, bg, normal, pressed)` is
called immediately. There is no animated interpolation and no continuous
screen capture.

The language-cycle action traverses enabled IMEs and their enabled subtypes in
a bounded circular pass. It skips only subtypes for which `getMode()` returns
exactly `voice`; other modes, including handwriting and vendor-defined values,
are retained. An IME with no exposed subtypes may still be selected with its
default subtype, while an IME exposing only voice subtypes is skipped.

Toolbar haptics are injected into the action listener `onClick(View)` methods,
not into fixed left/right containers. Each supported action therefore calls
`View.performHapticFeedback(3)`, where `3` is
`HapticFeedbackConstants.KEYBOARD_TAP`, wherever it is assigned. This path
needs no vibration permission and respects Android's
system haptic-feedback setting. The covered listeners are input-method switch,
keyboard cycle, language cycle, voice input, and clipboard/frequent phrases.
