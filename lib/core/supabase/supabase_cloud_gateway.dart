import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../config/cloud_status.dart';
import 'cloud_gateway.dart';

/// [CloudGateway] backed by a real `SupabaseClient`.
///
/// Constructed **only** when [AppConfig.evaluate] returned
/// [CloudStatus.cloudConfigured]; otherwise [GuestCloudGateway] is used and
/// this class is never instantiated. That is what keeps a missing or malformed
/// dart-define from crashing startup.
///
/// `SupabaseClient` is deliberately **not** part of the [CloudGateway]
/// interface: features reach cloud data only through this concrete type in
/// Phase 07, so offline features never hold a network handle (PRD §3.1).
class SupabaseCloudGateway implements CloudGateway {
  SupabaseCloudGateway({
    required AppConfig config,
    SupabaseInitializer? initializer,
  }) : this._(config, initializer ?? const _DefaultSupabaseInitializer());

  SupabaseCloudGateway._(this._config, this._initializer)
    : _status = CloudStatus.cloudConfigured,
      _statusReason = 'config_valid';

  final AppConfig _config;
  final SupabaseInitializer _initializer;

  CloudStatus _status;
  String _statusReason;

  @override
  CloudStatus get status => _status;

  @override
  String get statusReason => _statusReason;

  @override
  bool get isCloudLive => _status == CloudStatus.cloudInitialized;

  @override
  bool get isAuthenticated {
    final clientOrNull = _liveClientOrNull();
    if (clientOrNull == null) return false;
    return clientOrNull.auth.currentSession != null;
  }

  /// Live client, or `null` when no Supabase client actually exists.
  ///
  /// Phase 00 never exposes this to feature code; Phase 07 sync work will add
  /// scoped methods to [CloudGateway] instead of leaking the raw client.
  SupabaseClient? get client => _liveClientOrNull();

  /// Never throws: `Supabase.instance` asserts when no client has been built
  /// (an injected initializer in tests, or a client torn down at runtime).
  /// Treating that as "no client" keeps the guest shell alive instead of
  /// crashing the app.
  SupabaseClient? _liveClientOrNull() {
    if (!isCloudLive) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> initialize() async {
    if (_status != CloudStatus.cloudConfigured) return;

    final evaluation = _config.evaluate();
    if (evaluation.status != CloudStatus.cloudConfigured) {
      _status = evaluation.status;
      _statusReason = evaluation.reason;
      return;
    }

    try {
      await _initializer.call(
        url: _config.supabaseUrl.trim(),
        publishableKey: _config.supabasePublishableKey.trim(),
      );
      _status = CloudStatus.cloudInitialized;
      _statusReason = 'initialized';
    } catch (_) {
      // Deliberately swallow details: exception text can embed the project URL
      // and request headers. Report a stable token instead.
      _status = CloudStatus.cloudError;
      _statusReason = 'initialize_failed';
    }
  }

  static Future<void> _initializeSupabase({
    required String url,
    required String publishableKey,
  }) async {
    // supabase_flutter 2.18.x: `publishableKey` is the supported parameter;
    // `anonKey` is deprecated and intentionally not used.
    await Supabase.initialize(url: url, publishableKey: publishableKey);
  }
}

/// Production [SupabaseInitializer]: the only place in the app that creates a
/// `SupabaseClient`.
class _DefaultSupabaseInitializer implements SupabaseInitializer {
  const _DefaultSupabaseInitializer();

  @override
  Future<void> call({required String url, required String publishableKey}) =>
      SupabaseCloudGateway._initializeSupabase(
        url: url,
        publishableKey: publishableKey,
      );
}
