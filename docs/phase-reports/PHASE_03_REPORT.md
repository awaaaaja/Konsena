# PHASE 03 REPORT — Android Permission Inspector

## Status

**PASS.** Samsung SM-A556E (serial `RRCY102L98L`, Android API 36) verified S04/S05
and Android Settings. Real app `jalanku` showed `ACCESS_FINE_LOCATION` granted,
consistent with Settings; returning from Settings refreshed capture time. An
owned disposable fixture verified granted, denied, Settings comparison,
refresh, uninstall/requery, and historical/unavailable handling without
changing any third-party permission. Flutter (97 tests), analyze, Gradle tests
(JDK 21), debug APK build/install, source/merged-manifest review and diff checks
pass. Phase 04 is now unblocked but remains `NOT_STARTED`.

## READ — repository and environment findings

- Phase 02 is **PASS — automated gate** in `PHASE_STATUS.md`; its report records
  analyzer, data/security tests, full suite, build, formatter, and diff checks.
- Flutter **3.47.8 stable**, Dart **3.13.7**. Android SDK directory is
  `$HOME/develop/android-sdk`; installed platforms are `android-35` and
  `android-36`. App Gradle configuration uses Flutter defaults, documented in
  the file as minSdk 24, compile/target SDK 36, Java/Kotlin 17. Gradle wrapper
  and wrapper JAR are present.
- `$HOME/develop/android-sdk/platform-tools/adb` is ADB **1.0.41**, version
  **37.0.1-15733141**. Initial probe: zero devices. Recheck after operator
  reported connection: serial **RRCY102L98L**, `device`, USB `2-2.3`, product
  `a55xnsxx`, model **SM-A556E**, manufacturer Samsung, Android SDK **36**.
  `android-sdk/emulator/emulator` is absent; emulator tooling is not needed while
  the real device is connected. `adb` was not on PATH, so use its SDK path.
- `android/app/src/main/AndroidManifest.xml` currently declares only a
  `PROCESS_TEXT` intent query. It has no `QUERY_ALL_PACKAGES`, no launcher
  visibility query, and no permission-inspection bridge. `MainActivity.kt` is
  the default `FlutterActivity` with no MethodChannel/Pigeon handler.
- Existing Flutter routes S04 (`/audit/apps`) and S05
  (`/audit/apps/:package`) are explicit phase placeholders in
  `lib/app/navigation/route_registry.dart`; `app_router.dart` uses the generic
  route screen for them. No permission inspector domain/data/UI or persisted
  snapshot schema currently exists.
- PRD §4.3 and §3.5 define channel `id.konsena/permissions` and methods
  `listVisibleLaunchableApps`, `getPermissionSnapshot`, `openAppSettings`, plus
  structured errors. The requested fact contract includes package/version,
  requested permissions, nullable grant/status facts, Android SDK and capture
  timestamp. Existing PRD caveats rule out usage tracking, whole-device claims,
  and programmatic changes to third-party permissions.
- Android's official Package Visibility documentation was fetched for this
  review: <https://developer.android.com/training/package-visibility>. For apps
  targeting API 30+, PackageManager query results are filtered; `<queries>` is
  the selective mechanism and `QUERY_ALL_PACKAGES` is exceptional and subject
  to Play approval. This phase plan therefore uses a launcher-intent query and
  does not add the broad permission. The OS-visible set must be labeled as
  limited, not exhaustive.

## THINK — implementation decisions

### Contract and behavior

1. Add a typed Flutter service boundary over MethodChannel
   `id.konsena/permissions`. Kotlin will list only apps returned by
   `PackageManager.queryIntentActivities(ACTION_MAIN + CATEGORY_LAUNCHER)`;
   optional system-app filtering will happen after the visible results are
   obtained. Never enumerate and expose all installed packages.
2. Declare only the launcher intent in `<queries>` alongside the existing
   `PROCESS_TEXT` query. Do not request `QUERY_ALL_PACKAGES`.
3. For a selected, visible package, query PackageInfo with API-compatible
   flags (`PackageInfoFlags` on API 33+, deprecated integer flags on older
   supported releases). Return package id, label/version, requested permission
   names, SDK, and UTC `capturedAt`. Use the OS `REQUESTED_PERMISSION_GRANTED`
   flag as a grant fact when present. Map absent permission metadata, null
   arrays, unsupported API facts, special/non-runtime permissions, and
   unresolvable labels to an explicit unknown/unavailable status; never infer
   denied or usage from missing data.
4. Open only the system app-details Settings intent for the selected package.
   Handle missing activity/package errors; KONSENA will not request, grant, or
   revoke permissions. Refresh after returning to S05/on explicit user action.
5. S04 will disclose launcher-only visibility, provide search and refresh, and
   treat an empty/failed list as “no visible results / unavailable”, not “no
   apps installed”. S05 will display only snapshot facts and capture time, with
   statuses `Diberikan`, `Belum diberikan`, and `Tidak tersedia`.
6. Persist each user-requested snapshot in Drift with audit/package
   provenance, capture time and SDK; handle deleted apps as unavailable and keep
   prior snapshot history distinguishable from current installed state. Use a
   schema migration and the existing local encryption/key policy for sensitive
   fields. No background polling or usage telemetry.

### Planned files/modules

- `android/app/src/main/AndroidManifest.xml`,
  `android/app/src/main/kotlin/id/konsena/ai/MainActivity.kt` — narrow query and
  MethodChannel handler.
- `android/app/src/test/...` — Kotlin unit tests for API mapping and error
  handling (instrumentation/device checks remain separate).
- `lib/features/permission_inspector/{domain,data,presentation}/` — models,
  platform service/fake, repository/state, S04 list and S05 detail.
- `lib/data/local/app_database.dart` and generated companion, plus a focused
  permission-snapshot repository/migration and tests.
- `lib/app/app_router.dart`, `lib/app/navigation/route_registry.dart` only for
  connecting S04/S05 and return/refresh behavior.
- `test/features/permission_inspector/`, `test/data/` — MethodChannel fake
  contract, schema/provenance/status, empty/error/uninstalled cases, search and
  Settings routing contract.
- `docs/phase-reports/PHASE_03_REPORT.md`, `PHASE_STATUS.md`,
  `KNOWN_ISSUES.md`, and traceability/evidence only as actual results justify.

### Dependencies, risks, verification, rollback

- Planned dependencies: existing Flutter `MethodChannel`, Android framework
  `PackageManager`/`PackageInfo`/`Settings` APIs, existing Drift and crypto
  dependencies. No third-party package or broad permission is currently
  justified.
- Risks: Android 11+ package filtering; work profiles/OEM differences; API 33
  typed flags; requested permission list absent; grant flags do not prove
  permission usage; Settings intent/package uninstall races; localized/unknown
  labels; migrations must preserve Phase 02 local data.
- Planned checks: Dart analyze; Flutter full suite and fake-channel contract;
  schema migration/repository tests; `cd android && ./gradlew test`; debug APK;
  merged-manifest audit for absence of `QUERY_ALL_PACKAGES`; then on a recorded
  real device/API level compare a visible app's requested/granted values with
  Settings, open Settings and refresh, test a denied runtime permission,
  uninstall/requery, and verify visibility-limited/empty/error behavior.
- Rollback: isolate the new inspector/channel and schema migration; remove its
  route wiring and added query/bridge without reverting Phase 02 or unrelated
  working-tree changes. If snapshots have shipped, preserve database migration
  compatibility and use a forward migration rather than destructive reset.

## BUILD — implementation and evidence

- Native MethodChannel `id.konsena/permissions` lists only launcher-visible
  applications using the declared launcher `<queries>` intent, returns requested
  permission/grant facts and timestamps, and opens only the user-selected app's
  Android details Settings page. No `QUERY_ALL_PACKAGES` was added.
- S04/S05 are wired to the inspector; UI explains limited visibility and that
  grant facts are not usage tracking. Snapshot data is encrypted in Drift schema
  v2, with application/permission provenance and cascade cleanup.
- Automated tests cover v1→v2 migration, encrypted snapshot persistence and
  cascade deletion, empty-permission snapshots, MethodChannel contract/native
  grant mapping, S04 search/empty states and S05 fact/Settings behavior.
- Device: latest debug APK rebuilt and installed successfully at
  `build/app/outputs/flutter-apk/app-debug.apk`. Capture
  `/tmp/opencode/phase03/s04_verified_top.png` shows launcher-visible apps
  including `jalanku`; `settings_permissions.png` records Android Settings.
  S05 snapshot and refresh were inspected via Android accessibility hierarchy. For
  `jalanku`, Android Settings showed Camera/Location/Microphone allowed and no
  denied permissions; S05 showed `ACCESS_FINE_LOCATION` as `Diberikan`. After
  returning from Settings, the capture timestamp advanced from
  `2026-11-08 00:52:52.545` to `2026-11-08 00:54:47.571`.
- Owned disposable fixture `id.konsena.phase03_permission_fixture` requested
  CAMERA. On SM-A556E/API 36, Android reported the permission granted and S05
  showed `Diberikan`; after `pm revoke` on this fixture only, Android Settings
  showed Camera under “Tidak diizinkan” and S05 showed `Belum diberikan`.
  Returning from Settings refreshed the displayed capture time. The fixture was
  then uninstalled; refreshing S05 showed the unavailable/not-current message,
  and S04 refresh/search no longer found its package. No third-party app or
  permission was changed. Screenshots: `fixture_granted.png`,
  `fixture_denied_settings.png`, `fixture_uninstalled_list.png` in
  `/tmp/opencode/phase03/`.

## REVIEW — evidence available at this gate

| Check | Result | Evidence |
|---|---|---|
| Phase 02 prerequisite | **PASS** | `PHASE_STATUS.md` and Phase 02 final gate |
| Flutter/Android SDK and Gradle wrapper audit | **READ** | Flutter 3.47.8/Dart 3.13.7; SDK platforms 35/36; wrapper present |
| Manifest query scope | **PASS** | Explicit launcher query is present, `QUERY_ALL_PACKAGES` absent; merged manifest also contains file-picker intents from dependencies |
| Device/emulator available | **PASS** | Samsung SM-A556E, API 36, serial `RRCY102L98L` |
| `flutter analyze` | **PASS** | No issues found after Phase 03 changes |
| Focused Flutter inspector/persistence tests | **PASS** | 20 tests passed for audit persistence and inspector features |
| Full Flutter test suite | **PASS** | `flutter test` — all 97 tests passed after updating S04/S05 route expectations and malformed-package recovery |
| Android app Kotlin unit tests | **PASS** | `:app:testDebugUnitTest` passed in `./gradlew test` |
| Full `./gradlew test` | **PASS** | `BUILD SUCCESSFUL` in 8m15s using process-local Temurin 21.0.13; all plugin and app unit-test tasks completed |
| Debug APK + install | **PASS** | Latest `flutter build apk --debug`; `adb install -r` succeeded on SM-A556E |
| Device snapshot vs Settings + return refresh | **PASS (owned fixture + real app)** | Jalanku location and fixture CAMERA granted/denied facts matched Settings; returning refreshed capture time |
| Denied permission and uninstall/requery | **PASS (owned fixture)** | Camera denied matched S05; uninstalled fixture disappeared from S04 and S05 displayed historical/unavailable state |

## GATE

**PASS — Phase 03 gate complete.** Phase 02 remains PASS; all required Flutter
and Gradle checks pass, the latest APK is installed, and device snapshot/Settings,
refresh, denied and uninstall/requery checks pass on SM-A556E/API 36. No
third-party permission was modified and `QUERY_ALL_PACKAGES` is absent. Phase 04
is the next phase and is `NOT_STARTED`.
