import 'package:flutter_test/flutter_test.dart';
import 'package:konsena_ai/core/config/app_config.dart';
import 'package:konsena_ai/core/config/cloud_status.dart';

/// Builds a config; omitted fields are empty/false like a real build with no
/// `--dart-define` at all.
AppConfig _config({
  String url = '',
  String key = '',
  bool cloudSync = false,
  bool ml = false,
  bool demo = false,
}) => AppConfig(
  supabaseUrl: url,
  supabasePublishableKey: key,
  enableCloudSync: cloudSync,
  enableMl: ml,
  enableDemo: demo,
);

void main() {
  group('AppConfig — guest-first defaults (PRD §3.3)', () {
    test('empty environment resolves to cloudNotConfigured, never throws', () {
      final evaluation = _config().evaluate();

      expect(evaluation.status, CloudStatus.cloudNotConfigured);
      expect(evaluation.reason, 'url_missing');
    });

    test('feature flags default to false when the defines are absent', () {
      final config = _config();

      expect(config.enableCloudSync, isFalse);
      expect(config.enableMl, isFalse);
      expect(config.enableDemo, isFalse);
    });

    test('valid config with ENABLE_CLOUD_SYNC=false stays cloudDisabled', () {
      final evaluation = _config(
        url: 'https://abcdefghijkl.supabase.co',
        key: 'sb_publishable_abcdefghijklmnopqrstuvwxyz012345-_',
      ).evaluate();

      expect(evaluation.status, CloudStatus.cloudDisabled);
      expect(evaluation.reason, 'enable_cloud_sync_false');
    });

    test('valid config with cloud sync enabled becomes cloudConfigured', () {
      final evaluation = _config(
        url: 'https://abcdefghijkl.supabase.co',
        key: 'sb_publishable_abcdefghijklmnopqrstuvwxyz012345-_',
        cloudSync: true,
      ).evaluate();

      expect(evaluation.status, CloudStatus.cloudConfigured);
      expect(evaluation.reason, 'config_valid');
    });
  });

  group('AppConfig — URL validation', () {
    test('rejects plain http', () {
      expect(
        _config(url: 'http://abcdefghijkl.supabase.co').evaluate().reason,
        'url_not_https',
      );
    });

    test('rejects a URL that embeds credentials', () {
      expect(
        _config(url: 'https://user:pass@abcdefghijkl.supabase.co')
            .evaluate()
            .reason,
        'url_contains_credentials',
      );
    });

    test('rejects placeholder templates from dev.example.json', () {
      expect(
        _config(url: 'https://YOUR_PROJECT_REF.supabase.co').evaluate().reason,
        'url_placeholder',
      );
      expect(
        _config(url: 'https://<project-ref>.supabase.co').evaluate().reason,
        'url_placeholder',
      );
    });

    test('rejects a URL with no host', () {
      expect(
        _config(url: 'https://').evaluate().reason,
        anyOf('url_unparsable', 'url_missing_host'),
      );
    });

    test('accepts a normal https project url', () {
      expect(
        _config(
          url: 'https://abcdefghijkl.supabase.co',
          key: 'sb_publishable_abcdefghijklmnopqrstuvwxyz012345-_',
          cloudSync: true,
        ).evaluate().status,
        CloudStatus.cloudConfigured,
      );
    });
  });

  group('AppConfig — credential guard (P0 security)', () {
    test('refuses an sb_secret_ key even if supplied via dart-define', () {
      final evaluation = _config(
        url: 'https://abcdefghijkl.supabase.co',
        key: 'sb_secret_abcdefghijklmnopqrstuvwxyz012345-_',
        cloudSync: true,
      ).evaluate();

      expect(evaluation.status, CloudStatus.cloudNotConfigured);
      expect(evaluation.reason, 'key_rejected_secret_key');
    });

    test('refuses a JWT whose role claim is service_role', () {
      // header.payload.signature with payload {"role":"service_role",...}.
      // The validator only reads the (untrusted) claim in order to refuse it.
      const header = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9';
      const payload = 'eyJyb2xlIjoic2VydmljZV9yb2xlIiwiaXNzIjoic3VwYWJhc2UifQ';
      final evaluation = _config(
        url: 'https://abcdefghijkl.supabase.co',
        key: '$header.$payload.c2lnbmF0dXJl',
        cloudSync: true,
      ).evaluate();

      expect(evaluation.status, CloudStatus.cloudNotConfigured);
      expect(evaluation.reason, 'key_rejected_role_service_role');
    });

    test('accepts a legacy JWT-shaped anon key (role=anon)', () {
      const header = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9';
      const payload = 'eyJyb2xlIjoiYW5vbiIsImlzcyI6InN1cGFiYXNlIn0';
      expect(
        _config(
          url: 'https://abcdefghijkl.supabase.co',
          key: '$header.$payload.c2lnbmF0dXJl',
          cloudSync: true,
        ).evaluate().status,
        CloudStatus.cloudConfigured,
      );
    });

    test('refuses a JWT-shaped key whose payload cannot be decoded', () {
      // Looks like a JWT but is not structurally decodable -> refused rather
      // than silently accepted.
      expect(
        _config(
          url: 'https://abcdefghijkl.supabase.co',
          key: 'eyJhbGciOiJIUzI1NiJ9.unparsable',
          cloudSync: true,
        ).evaluate().reason,
        'key_unrecognised_format',
      );
    });

    test('refuses placeholder and unrecognised key material', () {
      expect(
        _config(
          url: 'https://abcdefghijkl.supabase.co',
          key: 'YOUR_PUBLISHABLE_KEY',
          cloudSync: true,
        ).evaluate().reason,
        'key_placeholder',
      );
      expect(
        _config(
          url: 'https://abcdefghijkl.supabase.co',
          key: 'not-a-key',
          cloudSync: true,
        ).evaluate().reason,
        'key_unrecognised_format',
      );
    });
  });

  group('AppConfig — redaction', () {
    test('describe() never leaks the key material', () {
      const key = 'sb_publishable_supersecretvalue';
      final description = _config(
        url: 'https://abcdefghijkl.supabase.co',
        key: key,
      ).describe();

      expect(description, isNot(contains(key)));
      expect(description, isNot(contains('supersecretvalue')));
      expect(description, contains('key: <set>'));
    });

    test('evaluation reason never leaks host or key', () {
      const key = 'sb_publishable_supersecretvalue';
      final evaluation = _config(
        url: 'https://abcdefghijkl.supabase.co',
        key: key,
        cloudSync: true,
      ).evaluate();

      expect(evaluation.reason, isNot(contains('abcdefghijkl')));
      expect(evaluation.reason, isNot(contains('supersecretvalue')));
    });
  });
}
