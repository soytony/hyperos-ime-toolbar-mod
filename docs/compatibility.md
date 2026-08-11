# Compatibility And Risks

The reference device is a POCO 2510DPC44G (`annibale`) running HyperOS
`OS3.0.307.0.WPKCNXM`, Android 16 / SDK 36.

This is not a generic Android module. Method names, dex layout, Android API
behavior, Xiaomi package filtering, and archive contents can differ per ROM
release. Port every patch from the target build's decoded artifacts.

The module intentionally changes input-method package visibility and
privileged switching behavior. Keep it restricted to a trusted device.

Known working functional state:

- Full-screen IME toolbar is visible for Gboard and WeChat Input Method.
- Toolbar picker can switch WeChat Input Method to Gboard.
- Cycle keyboard selects the next enabled IME directly.

When debugging, distinguish these failure classes:

- Toolbar missing: check that the overlaid `MiuiFrequentPhrase.apk` still
  contains resources and was not reduced to only dex entries.
- Gboard selection crashes WeChat: inspect `Unknown id` in `logcat`; this
  indicates server-side visibility validation remains active.
- Cycle action does nothing: do not assume `switchToNextInputMethod()` works
  on this HyperOS build; inspect the enabled list and use direct list cycling.
