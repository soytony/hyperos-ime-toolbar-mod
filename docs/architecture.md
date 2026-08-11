# Architecture

## KernelSU overlay

The module uses KernelSU Hybrid Mount to overlay these files:

```text
/product/app/MiuiFrequentPhrase/MiuiFrequentPhrase.apk
/system_ext/priv-app/Settings/Settings.apk
/system_ext/framework/miui-framework.jar
/system/framework/services.jar
```

## Patches

`Settings.apk`

- `InputMethodFunctionSelectUtils.isMiuiImeBottomSupport()` returns `true`.

`miui-framework.jar`

- `InputMethodServiceInjector.isImeSupport(Context)` returns `true`.

`MiuiFrequentPhrase.apk`

- `InputMethodBottomManager.isImeSupport(...)` returns `true`.
- The IME picker obtains the enabled input method list without Xiaomi's
  package allowlist.
- `switchKeyboardType()` gets Android's enabled IME list, finds the current
  secure setting `default_input_method`, wraps to the next entry, and calls
  `InputMethodService.switchInputMethod(nextId)`.
- `switchKeyboardLanguage()` calls
  `InputMethodService.switchToNextInputMethod(true)`. The `true` argument asks
  Android to remain in the current IME and advance its subtype/language. This
  replaces Xiaomi's private `SWITCH_KEYBOARD_LANGUAGE` broadcast, which Gboard
  does not handle.

`services.jar`

- Prevent enabled IMEs from being hidden by package-visibility filtering.
- Let the privileged IME switch path accept a target already resolved from the
  service method map. This prevents an enabled but visibility-filtered Gboard
  target from being rejected as `Unknown id` when invoked by WeChat Input
  Method.

## Why the cycle action does not use switchToNextInputMethod

Android exposes `InputMethodService.switchToNextInputMethod(false)`, but the
target HyperOS build's subtype switching controller filters and/or declines
WeChat Input Method because it declares
`mSupportsSwitchingToNextInputMethod=false`. Calling the public API therefore
did not switch. Direct list/index selection remains framework-mediated,
wraps predictably, and works across IMEs.

## Flattened language cycle (v1.3.0)

The `v1.3.0` language action treats enabled IMEs and their framework-visible
subtypes as one circular sequence. It advances within the current IME when a
next subtype exists; after the last subtype it selects the next enabled IME and
its first subtype, wrapping to the first IME at the end. IMEs with no exposed
subtype are represented by a null/default subtype.

The sequence includes auxiliary/voice IMEs when Android reports them as
enabled. IMEs that keep language state internally or expose only one subtype
cannot be subdivided by the framework API.

## Dynamic color (v1.4.4)

After `mInputFrame` has been laid out, the bottom manager draws that local IME
view into a temporary ARGB bitmap and samples its bottom-centre pixel. This
matches the keyboard's bottom background without requiring screenshot or
cross-process capture permission. The sampled color is applied through the
existing `setBottomColor(...)` path; icon tint is selected by RGB brightness.

The `ColorDrawable` input-frame, root-view, and window-decor chain remains a
fallback for zero-sized or non-drawable views. Sampling occurs after
`changeViewForMiuiBottom()` has completed layout adjustment, not only when the
toolbar is first attached.
