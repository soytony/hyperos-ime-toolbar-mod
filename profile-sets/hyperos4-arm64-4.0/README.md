# HyperOS 4.0 arm64

Status: experimental, partial toolbar implementation.

The official HyperOS 4 sample was decoded on-device. Profiles in this
directory were copied only for declarations confirmed in that sample. Their
payloads still require functional validation on the target HyperOS 4 build.

Signature proof is split into caller-scoped `signature-proof` and
`signature-proof-session` profiles for `ScanPackageUtils` and
`PackageSessionVerifier`. Both use `expected_matches=all` within their class;
a global wildcard scan is intentionally avoided.

The core HyperOS 3 service methods do not match this build and remain
excluded. The provider allowlist is now mapped to HyperOS 4's `f()Z` method,
which performs the caller-package check. This set must still be treated as
experimental until the included payloads are functionally tested.

Observed service candidates (not yet profiles):

| HyperOS 3 behavior | HyperOS 4 candidate | Required work |
| --- | --- | --- |
| enabled IME list lambda | R8 lambda `...LR2zuz...` | confirmed signature; payload uses its boolean result register |
| subtype capability filter | R8 lambda `...t5j90...` | adapt `(List,Z)->List` replacement |
| next input method | `get(InputMethodInfo,Subtype,ZZIZ)` | adapt reordered parameters |
| user action | `onUserAction(InputMethodInfo,Subtype)` | validate body and replacement semantics |
| target selection | `setInputMethodAndSubtypeLocked(...)` | exact signature still present |
| voice target | `setInputMethodWithSubtypeIndexLocked(...)` | exact signature still present |

The exact-signature rows are enabled in `plan.conf` and passed extracted
artifact matching. Matching a declaration alone does not prove that its
callers and user-state semantics remain compatible, so this set remains
experimental.

The device-side builder rebuilds only changed DEX directories for JAR inputs.
This is required for the large HyperOS 4 `services.jar`; a full decoded-source
rebuild may abort on-device despite valid patched smali.

Required follow-up:

1. Recover the R8-generated InputMethodManagerService paths for enabled-list,
   next-IME, user-action, subtype filtering, and target selection.
2. Recover changed MIUIFrequentPhrase provider/listener/color signatures.
3. Capture local smali context and create positive/negative fixtures.
4. Add the four-artifact plan only after an end-to-end device patch succeeds.
