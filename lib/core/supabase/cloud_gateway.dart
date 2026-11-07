import '../config/cloud_status.dart';

/// The one seam through which a live Supabase client may be created.
///
/// Modelled as an interface rather than a bare function type so tests can
/// substitute a recorder and prove that startup performs **no** network writes
/// (no upload, no request).
abstract interface class SupabaseInitializer {
  Future<void> call({required String url, required String publishableKey});
}

/// The only cloud surface that features are allowed to depend on.
///
/// Feature modules must depend on this interface — never on
/// `Supabase.instance` or a raw Supabase client directly — so that local,
/// offline functionality keeps working when cloud is
/// [CloudStatus.cloudNotConfigured] or [CloudStatus.cloudDisabled]
/// (PRD §3.1, §13).
abstract interface class CloudGateway {
  /// Current lifecycle state.
  CloudStatus get status;

  /// Non-sensitive, machine readable reason behind [status].
  /// Never contains a URL host, key, token or any PII.
  String get statusReason;

  /// True only after `Supabase.initialize` succeeded.
  bool get isCloudLive;

  /// Whether the signed-in Supabase session exists.
  ///
  /// Phase 00 ships no sign-in flow, so this is always `false`; it exists so
  /// the guest contract can be asserted by tests.
  bool get isAuthenticated;

  /// Idempotent. Does nothing unless [CloudStatus.cloudConfigured].
  Future<void> initialize();
}
