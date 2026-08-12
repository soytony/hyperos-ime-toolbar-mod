# Architecture

## Install-time pipeline

```text
KernelSU customize.sh
  -> validate HyperOS 3.0+ and arm64
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
- `services.jar`: exposes enabled IMEs and accepts the direct target-switch
  path used by the toolbar.
- `MiuiFrequentPhrase.apk`: creates the toolbar, removes its IME allowlist,
  permits enabled IMEs to read the existing clipboard/frequent-phrase
  provider, cycles IMEs/languages, and updates toolbar colors.

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

## Runtime behavior

`system.prop` enables the HyperOS bottom view and `service.sh` sets the secure
enable flag after boot. Toolbar color sampling is event-driven after layout
and uses the rendered IME input frame; controls update immediately without
animated interpolation.
