# HyperOS 4 Patch Plan

## Version hierarchy

Profile sets are version-scoped and architecture-scoped:

```text
profile-sets/
  hyperos3-arm64-3.0/       validated toolbar implementation
  hyperos4-arm64-4.0/       experimental HyperOS 4 implementation
```

The installer selects the set from `ro.mi.os.version.name` after enforcing
arm64. HyperOS 3 selects `hyperos3-arm64-3.0`; HyperOS 4 selects
`hyperos4-arm64-4.0`. An unknown version retains the existing volume-up
confirmation gate. A profile set must never silently fall back to another
major-version set.

## Current evidence

The official HyperOS 4 artifacts were decoded on-device and copied to the
analysis output directory. `Settings.apk` and `miui-framework.jar` retain the
HyperOS 3 support-method signatures. `services.jar` does not: the old input
method service methods were removed or R8-renamed. `MIUIFrequentPhrase.apk`
retains most toolbar methods, but its provider allowlist method `c()Z` is
absent; the equivalent caller-package check is `InputProvider.f()Z`. The
HyperOS 4 set therefore contains confirmed Settings/framework/
phrase profiles and service profiles for the renamed IME-list predicates and
target-selection methods. Signature proof is caller-scoped: separate
`ScanPackageUtils` and `PackageSessionVerifier` profiles each use
`expected_matches=all` within their class; a global wildcard is not used.
The two R8-generated IME-list predicates are included with dedicated HyperOS 4
signatures and register-safe replacements; the remaining switching methods stay
excluded until their reordered arguments and local state semantics are adapted.

## HyperOS 4 implementation sequence

1. Decode each official HyperOS 4 artifact and record package, DEX, class,
   method signature, and enclosing-method context.
2. Map each old HyperOS 3 behavior to its HyperOS 4 R8-generated equivalent.
   Candidate methods must be selected by parameter/return types plus stable
   nearby instruction context, never by device name or whole-archive hash.
3. Add one profile directory per behavior under the HyperOS 4 set. Keep
   replacement smali beside `profile.conf`; do not reuse a HyperOS 3 payload
   until its register layout and invoked APIs are verified.
4. Add positive fixtures for every expected signature and negative fixtures for
   renamed, duplicated, and missing anchors. `expected_matches=all` is valid
   only for all-occurrence result overrides; whole-method replacement remains
   exact-count.
5. For R8-generated lambdas, first compare the lambda's delegate invocation
   with the HyperOS 3 method's contract. A matching parameter count is
   insufficient when argument order changed; adapt the replacement payload or
   use a local-context insertion instead.
6. Run the patcher in `inspect` mode against the extracted artifacts, then run
   the complete decode, smali patch, DEX injection, zipalign, and archive
   verification pipeline in an isolated work directory.
   For `services.jar`, the implementation rebuilds only the changed DEX
   source directories; rebuilding the complete decoded archive can abort on
   the device even when the patched smali is valid.
7. Install only after all four artifacts pass and reports identify the target
   DEX entries. Preserve original non-target entries and certificates.
8. Reboot, verify toolbar creation and each action with UIAutomator, and retain
   logs and patch reports with the tested OS build.

## Safety gates

- arm64 is mandatory.
- HyperOS 4 profiles must fail closed when a method or local anchor changes.
- Signature-proof remains an explicit volume-key choice and must be applied to
  every matching invocation when selected.
- No HyperOS 4 toolbar claim is valid until manual device testing succeeds.
