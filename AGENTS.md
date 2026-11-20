# Splash Finish project rules

- The local checkout is `~/GitHub/bobuk.io/splash-fihish` (the folder name has a
  typo); the GitHub repository is `bobuk-io/splash-finish`. Use
  `io.bobuk.splash-finish` for the app and `io.bobuk` for new identifiers.
- Shared UI and infrastructure come from BobukKit (`Vendor/BobukKit`, read-only); read
  `../BobukKit/README.md` before adding windows, panels, controls, hotkeys, file stores,
  processes or update code here, and follow `../AGENTS.md`. The release kit in
  `Scripts/release/` is a managed copy of `../BobukKit/ReleaseKit`; never edit it here.
- Releases use the shared release kit (`Scripts/release/README.md`); app facts live in
  `release.env`.
- `Scripts/release_next.sh` (no arguments) does the whole next patch release. Prepare
  `docs/releases/v<version>.md`, commit the landing copy (clean `../landing` on
  main), set `APP_IDENTITY` and `NOTARY_PROFILE`, and check readiness with
  `Scripts/release/doctor.sh`. After a failure, run the same command again.
- Every release must be signed with Developer ID, notarized and stapled, signed for
  Sparkle, published to GitHub Releases with `SHA256SUMS` and the GitHub
  `appcast.xml` (for 0.3.12 and older), published to the Homebrew tap,
  **installed at `/Applications/Splash Finish.app` and restarted**, and the landing
  site with `public/apps/splash-finish/appcast.xml` must be deployed.
- The Sparkle EdDSA private key stays in the login Keychain under account
  `io.bobuk.splash-finish`. Never export, print, commit or upload it.
- Release artifacts must also pass `Tests/test_packaged_resources.py`.
- After every release, update the Splash Finish pages on the landing site when the
  release needs it. See `../AGENTS.md`.
