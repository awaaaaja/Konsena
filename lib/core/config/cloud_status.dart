/// Lifecycle of the optional Supabase cloud layer.
///
/// KONSENA AI is guest-first and offline-first: every value here is a
/// *safe* value. The app must stay alive in [cloudNotConfigured] and
/// [cloudDisabled]; neither is an error state and neither may crash startup.
enum CloudStatus {
  /// `SUPABASE_URL` / publishable key missing, malformed, placeholder-like,
  /// or rejected as an admin credential. Guest mode only.
  cloudNotConfigured,

  /// Configuration is usable but `ENABLE_CLOUD_SYNC=false` (the default).
  /// Guest mode only; no network client is created.
  cloudDisabled,

  /// Configuration usable and cloud sync explicitly enabled, but
  /// `Supabase.initialize` has not completed yet.
  cloudConfigured,

  /// `Supabase.initialize` completed. Read/write still require Supabase Auth
  /// and RLS; nothing is uploaded automatically in Phase 00.
  cloudInitialized,

  /// Initialization was attempted and failed. The app keeps running as guest.
  cloudError,
}

/// Extension with non-sensitive, human readable labels for the UI and reports.
extension CloudStatusLabel on CloudStatus {
  String get label => switch (this) {
    CloudStatus.cloudNotConfigured => 'cloudNotConfigured',
    CloudStatus.cloudDisabled => 'cloudDisabled',
    CloudStatus.cloudConfigured => 'cloudConfigured',
    CloudStatus.cloudInitialized => 'cloudInitialized',
    CloudStatus.cloudError => 'cloudError',
  };

  /// Indonesian copy shown on screen (Phase 00 shell only).
  String get displayText => switch (this) {
    CloudStatus.cloudNotConfigured => 'Mode tamu — cloud belum dikonfigurasi',
    CloudStatus.cloudDisabled => 'Mode tamu — sinkronisasi cloud nonaktif',
    CloudStatus.cloudConfigured => 'Menyiapkan koneksi cloud…',
    CloudStatus.cloudInitialized => 'Cloud terhubung (sinkronisasi opt-in)',
    CloudStatus.cloudError => 'Cloud gagal tersambung — tetap mode tamu',
  };

  /// Whether a live [SupabaseClient] may be handed to upper layers.
  bool get isCloudLive => this == CloudStatus.cloudInitialized;
}
