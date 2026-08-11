# HyperOS Universal IME Toolbar Mod

KernelSU module notes and patch snippets for restoring HyperOS full-screen IME
toolbar support for all enabled input methods.

The module targets a HyperOS EU Android 16 device. It enables the bottom
toolbar, removes Xiaomi's IME allowlist, makes enabled IMEs visible to the
switcher, and provides a next-enabled-IME action.

## Repository layout

- `docs/architecture.md`: module layout and behavioral changes.
- `docs/build-and-install.md`: reproducible build, packaging, and verification.
- `docs/compatibility.md`: device assumptions and known risks.
- `snippets/`: focused smali and shell fragments for future ports.
- `out/`: ignored local output for release ZIPs, rebuilt dex files, and decoded
  working copies.

## Current reference release

`v1.3.0` is the working reference release. It contains the universal toolbar,
IME picker visibility fixes, a generic cycle-next-enabled-IME action, and a
flattened `(IME, subtype)` language cycle.

Do not re-sign any overlaid APK or JAR. The target device must already accept
the modified system artifacts without certificate replacement.
