import 'dart:convert';

import 'cloud_status.dart';

/// Build-time configuration for KONSENA AI.
///
/// Injected with `--dart-define` or `--dart-define-from-file=tool/env/dev.json`.
/// See `tool/env/dev.example.json` for the placeholder template.
///
/// **Security contract**
///
/// Only the *publishable* client key may appear here. It is safe inside an APK
/// solely because every table and storage object is protected by RLS.
/// The validator below actively refuses `service_role` / `sb_secret_*` material
/// so that a leaked admin credential in a dart-define file cannot be loaded
/// even by accident.
class AppConfig {
  const AppConfig({
    required this.supabaseUrl,
    required this.supabasePublishableKey,
    required this.enableCloudSync,
    required this.enableMl,
    required this.enableDemo,
  });

  /// Reads the compile-time defines. Missing values become empty strings and
  /// `false`, which is the guest-first default — never a crash.
  factory AppConfig.fromEnvironment() {
    const publishable = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
    // Legacy fallback: SDK 2.18.x supports `publishableKey`, so `anonKey`
    // (deprecated in supabase_flutter) is intentionally never used. The legacy
    // define is accepted only as an alternate *input* for older JWT-shaped keys.
    const legacy = String.fromEnvironment('SUPABASE_ANON_KEY');
    return AppConfig(
      supabaseUrl: const String.fromEnvironment('SUPABASE_URL'),
      supabasePublishableKey: publishable.isEmpty ? legacy : publishable,
      enableCloudSync: const bool.fromEnvironment('ENABLE_CLOUD_SYNC'),
      enableMl: const bool.fromEnvironment('ENABLE_ML'),
      enableDemo: const bool.fromEnvironment('ENABLE_DEMO'),
    );
  }

  /// `https://<project-ref>.supabase.co` (no trailing secret, no credentials).
  final String supabaseUrl;

  /// Publishable (anon) client key. Never a service role / secret key.
  final String supabasePublishableKey;

  /// Master opt-in for cloud sync. Default `false` (PRD §3.3).
  final bool enableCloudSync;

  /// ONNX/ML feature flag. Default `false` until Phase 09 (PRD §3.3).
  final bool enableMl;

  /// Demo fixtures flag. Default `false` in release (PRD §3.3).
  final bool enableDemo;

  /// Produces the effective [CloudStatus] plus a machine-readable reason.
  ///
  /// The reason string never contains the URL host or the key, so it is safe to
  /// print in logs and paste into phase reports.
  AppConfigEvaluation evaluate() {
    final urlCheck = _checkUrl(supabaseUrl);
    if (urlCheck != null) {
      return AppConfigEvaluation(
        status: CloudStatus.cloudNotConfigured,
        reason: urlCheck,
      );
    }

    final keyCheck = _checkKey(supabasePublishableKey);
    if (keyCheck != null) {
      return AppConfigEvaluation(
        status: CloudStatus.cloudNotConfigured,
        reason: keyCheck,
      );
    }

    if (!enableCloudSync) {
      return const AppConfigEvaluation(
        status: CloudStatus.cloudDisabled,
        reason: 'enable_cloud_sync_false',
      );
    }

    return const AppConfigEvaluation(
      status: CloudStatus.cloudConfigured,
      reason: 'config_valid',
    );
  }

  /// Non-sensitive description. Never includes the key.
  String describe() =>
      'AppConfig(url: ${supabaseUrl.isEmpty ? '<empty>' : '<set>'}, '
      'key: ${supabasePublishableKey.isEmpty ? '<empty>' : '<set>'}, '
      'cloudSync: $enableCloudSync, ml: $enableMl, demo: $enableDemo, '
      'status: ${evaluate().status.label}, reason: ${evaluate().reason})';

  // ---------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------

  /// Returns a failure reason, or `null` when the URL is acceptable.
  static String? _checkUrl(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return 'url_missing';
    if (_looksLikePlaceholder(value)) return 'url_placeholder';

    final uri = Uri.tryParse(value);
    if (uri == null) return 'url_unparsable';
    if (!uri.hasAuthority || uri.host.isEmpty) return 'url_missing_host';
    if (uri.scheme != 'https') return 'url_not_https';
    // `https://user:pass@host` would smuggle a credential into the APK.
    if (uri.userInfo.isNotEmpty) return 'url_contains_credentials';
    return null;
  }

  /// Returns a failure reason, or `null` when the key is acceptable.
  static String? _checkKey(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return 'key_missing';
    if (_looksLikePlaceholder(value)) return 'key_placeholder';

    // Hard security stops: admin material must never reach the client.
    if (value.startsWith('sb_secret_')) return 'key_rejected_secret_key';
    if (value.toLowerCase().contains('service_role')) {
      return 'key_rejected_service_role';
    }

    if (value.startsWith('sb_publishable_')) return null;

    // Legacy JWT-shaped client key: the payload is untrusted, so we only read
    // it to *refuse* anything that is not a plain `anon` role. A string that
    // merely starts like a JWT but cannot be parsed is refused too.
    final looksLikeJwt =
        value.startsWith('eyJ') || value.split('.').length == 3;
    if (looksLikeJwt) {
      final role = _jwtRole(value);
      if (role == null) return 'key_unrecognised_format';
      if (role != 'anon') return 'key_rejected_role_$role';
      return null;
    }

    return 'key_unrecognised_format';
  }

  /// Cheap heuristics that catch `--dart-define-from-file` templates that were
  /// never filled in.
  static bool _looksLikePlaceholder(String value) {
    final v = value.toLowerCase();
    const markers = [
      'your-',
      '<',
      '>',
      'example',
      'placeholder',
      'replace_me',
      'replace-me',
      'changeme',
      'your_',
      'xxxx',
      'project_ref',
      'project-ref',
      'dummy',
    ];
    return markers.any(v.contains);
  }

  /// Decodes the `role` claim of a JWT without trusting it; returns `null`
  /// when the token is not a decodable JWT.
  static String? _jwtRole(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    try {
      final payload = jsonDecode(utf8.decode(base64Url.decode(_pad(parts[1]))));
      if (payload is! Map<String, dynamic>) return null;
      final role = payload['role'];
      return role is String ? role : null;
    } catch (_) {
      return null;
    }
  }

  static String _pad(String segment) {
    final remainder = segment.length % 4;
    return remainder == 0 ? segment : segment + '=' * (4 - remainder);
  }
}

/// Result of [AppConfig.evaluate].
class AppConfigEvaluation {
  const AppConfigEvaluation({required this.status, required this.reason});

  final CloudStatus status;

  /// Short, non-sensitive, machine readable token (e.g. `url_missing`).
  final String reason;

  @override
  String toString() => 'AppConfigEvaluation(${status.label}, $reason)';
}
