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
