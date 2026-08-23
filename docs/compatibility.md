# Compatibility And Risks

The installer requires arm64 and selects a versioned profile set. `OS3.*`
selects the validated `hyperos3-arm64-3.0` set. `OS4.*` selects the separate
experimental `hyperos4-arm64-4.0` set and requires a separate volume-up
confirmation. A different value is a warning rather than an
automatic rejection: the installer displays the detected value and requires a
volume-up confirmation to try patching. Volume down, or no input within 20
seconds, cancels the installation. There is no fallback from one major
version's profiles to another.

This is not a promise of compatibility with every HyperOS 3 or HyperOS 4 build: the profile
set is intentionally not bound to a device product or build fingerprint, and
compatibility is determined at install time by platform checks plus successful
method-signature and local anchor matching. A new system version still needs
fresh profile and functional validation.

HyperOS releases may rename classes, move them between DEX files, change
method prototypes, or alter local instruction context. Such changes must fail
closed and require a new profile; they must not be handled by broad textual
replacement.

The module overlays privileged system code and changes IME visibility and
switching behavior. Existing package certificates are preserved, but a ROM
that enforces system APK signature proof may reject modified code unless its
signature-proof behavior is already patched or the installer option is
enabled.

Manual validation is required for every new device and HyperOS release. The
only fully tested environment is REDMI K90 / POCO F8 Pro, HyperOS
`OS3.0.307.0.WPKCNXM`, Android 16 / SDK 36, arm64-v8a. On that environment the
following have been manually confirmed with Gboard and WeChat Input Method:

- Toolbar creation for third-party/enabled IMEs.
- Input-method selection and wraparound keyboard cycling.
- Cross-IME `(IME, subtype)` language traversal, excluding only subtypes whose
  mode is exactly `voice`.
- Routing to the current user's exact system default voice IME without crashing
  the source IME.
- Clipboard and frequent-phrase access.
- Dynamic toolbar background/control colors.
- Keyboard-tap haptic feedback for all five actions in either toolbar position.

Other devices, ROM regions, and builds remain untested. A boot loop must be
recovered by disabling/removing the module through KernelSU safe mode. The
project and its owner provide no warranty and accept no responsibility for
device damage, data loss, or downtime.
