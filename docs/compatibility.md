# Compatibility And Risks

The current profile set targets HyperOS 3.0+ on arm64. It is intentionally not
bound to a device product or build fingerprint. Compatibility is determined at
install time by platform checks and by successful signature/anchor matching.

HyperOS releases may rename classes, move them between DEX files, change
method prototypes, or alter local instruction context. Such changes must fail
closed and require a new profile; they must not be handled by broad textual
replacement.

The module overlays privileged system code and changes IME visibility and
switching behavior. Existing package certificates are preserved, but a ROM
that enforces system APK signature proof may reject modified code unless its
signature-proof behavior is already patched or the installer option is
enabled.

Manual validation is required for every new HyperOS release. The reference
functional expectations are: toolbar creation for third-party IMEs, switching
between enabled IMEs, language traversal across `(IME, subtype)` pairs, and
dynamic toolbar color updates after IME layout. When a default voice IME is
configured, the voice shortcut must switch to that exact service from both
Gboard and WeChat Input Method without crashing either IME process.
