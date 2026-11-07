import 'package:shared_preferences/shared_preferences.dart';

/// Consent version written when the user completes S02.
///
/// Kept in one place so Phase 01B (Drift-backed preferences) can migrate this
/// value instead of inventing a second one.
const int kPrivacyConsentVersion = 1;

/// Local, account-free journey flags (S01/S02 state contract).
///
/// Everything here lives on the device only. There is no network read/write:
/// guest-first means these flags never leave the phone.
class JourneySnapshot {
  const JourneySnapshot({
    this.onboardingSeen = false,
    this.privacySetupSeen = false,
    this.cloudOptIn = false,
    this.analyticsOptIn = false,
    this.consentVersion = 0,
  });

  /// Result for a brand-new install (no flags stored yet).
  factory JourneySnapshot.firstRun() => const JourneySnapshot();

  /// Result where both S01 and S02 already completed (app opens on S03).
  factory JourneySnapshot.completed() => const JourneySnapshot(
    onboardingSeen: true,
    privacySetupSeen: true,
    consentVersion: kPrivacyConsentVersion,
  );

  final bool onboardingSeen;
  final bool privacySetupSeen;

  /// PRD/§S02: cloud sync is **opt-in and off by default**.
  final bool cloudOptIn;

  /// Analytics is **opt-in and off by default**.
  final bool analyticsOptIn;

  /// Version of the privacy consent the user agreed to (0 = none yet).
  final int consentVersion;

  JourneySnapshot copyWith({
    bool? onboardingSeen,
    bool? privacySetupSeen,
    bool? cloudOptIn,
    bool? analyticsOptIn,
    int? consentVersion,
  }) {
    return JourneySnapshot(
      onboardingSeen: onboardingSeen ?? this.onboardingSeen,
      privacySetupSeen: privacySetupSeen ?? this.privacySetupSeen,
      cloudOptIn: cloudOptIn ?? this.cloudOptIn,
      analyticsOptIn: analyticsOptIn ?? this.analyticsOptIn,
      consentVersion: consentVersion ?? this.consentVersion,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is JourneySnapshot &&
      other.onboardingSeen == onboardingSeen &&
      other.privacySetupSeen == privacySetupSeen &&
      other.cloudOptIn == cloudOptIn &&
      other.analyticsOptIn == analyticsOptIn &&
      other.consentVersion == consentVersion;

  @override
  int get hashCode => Object.hash(
    onboardingSeen,
    privacySetupSeen,
    cloudOptIn,
    analyticsOptIn,
    consentVersion,
  );
}

/// Persistence seam for the journey flags.
///
/// Two implementations exist on purpose:
///  * [InMemoryJourneyStore] — deterministic, used by every test and as the
///    documented fallback when no platform storage is available;
///  * [PreferencesJourneyStore] — the real on-device store used by the app.
abstract class JourneyStore {
  Future<JourneySnapshot> load();

  Future<void> setOnboardingSeen();

  Future<void> setPrivacySetupSeen({required bool cloudOptIn});

  Future<void> setCloudOptIn(bool value);

  Future<void> setAnalyticsOptIn(bool value);
}

/// In-memory store: never touches plugins, resets between tests.
class InMemoryJourneyStore implements JourneyStore {
  InMemoryJourneyStore([JourneySnapshot initial = const JourneySnapshot()])
    : _snapshot = initial;

  JourneySnapshot _snapshot;

  JourneySnapshot get snapshot => _snapshot;

  @override
  Future<JourneySnapshot> load() async => _snapshot;

  @override
  Future<void> setOnboardingSeen() async {
    _snapshot = _snapshot.copyWith(onboardingSeen: true);
  }

  @override
  Future<void> setPrivacySetupSeen({required bool cloudOptIn}) async {
    _snapshot = _snapshot.copyWith(
      privacySetupSeen: true,
      cloudOptIn: cloudOptIn,
      consentVersion: kPrivacyConsentVersion,
    );
  }

  @override
  Future<void> setCloudOptIn(bool value) async {
    _snapshot = _snapshot.copyWith(cloudOptIn: value);
  }

  @override
  Future<void> setAnalyticsOptIn(bool value) async {
    _snapshot = _snapshot.copyWith(analyticsOptIn: value);
  }
}

/// On-device store backed by `shared_preferences`.
///
/// A failure to read/write is surfaced to the caller — S00 turns that into its
/// recoverable-error state instead of silently pretending the user is new.
class PreferencesJourneyStore implements JourneyStore {
  PreferencesJourneyStore(this._prefs);

  static const String _kOnboardingSeen = 'journey.onboarding_seen';
  static const String _kPrivacySetupSeen = 'journey.privacy_setup_seen';
  static const String _kCloudOptIn = 'journey.cloud_opt_in';
  static const String _kAnalyticsOptIn = 'journey.analytics_opt_in';
  static const String _kConsentVersion = 'journey.consent_version';

  final SharedPreferences _prefs;

  @override
  Future<JourneySnapshot> load() async => JourneySnapshot(
    onboardingSeen: _prefs.getBool(_kOnboardingSeen) ?? false,
    privacySetupSeen: _prefs.getBool(_kPrivacySetupSeen) ?? false,
    cloudOptIn: _prefs.getBool(_kCloudOptIn) ?? false,
    analyticsOptIn: _prefs.getBool(_kAnalyticsOptIn) ?? false,
    consentVersion: _prefs.getInt(_kConsentVersion) ?? 0,
  );

  @override
  Future<void> setOnboardingSeen() => _prefs.setBool(_kOnboardingSeen, true);

  @override
  Future<void> setPrivacySetupSeen({required bool cloudOptIn}) async {
    await _prefs.setBool(_kPrivacySetupSeen, true);
    await _prefs.setBool(_kCloudOptIn, cloudOptIn);
    await _prefs.setInt(_kConsentVersion, kPrivacyConsentVersion);
  }

  @override
  Future<void> setCloudOptIn(bool value) => _prefs.setBool(_kCloudOptIn, value);

  @override
  Future<void> setAnalyticsOptIn(bool value) =>
      _prefs.setBool(_kAnalyticsOptIn, value);
}
