import 'package:flutter_test/flutter_test.dart';
import 'package:konsena_ai/app/dependencies.dart';
import 'package:konsena_ai/core/config/app_config.dart';
import 'package:konsena_ai/core/config/cloud_status.dart';
import 'package:konsena_ai/core/supabase/cloud_gateway.dart';
import 'package:konsena_ai/core/supabase/guest_cloud_gateway.dart';
import 'package:konsena_ai/core/supabase/supabase_cloud_gateway.dart';

/// Records every initializer invocation so tests can prove exactly what (and
/// how often) startup touched the network seam.
class _RecordingInitializer implements SupabaseInitializer {
  final List<({String url, String key})> calls = [];
  Object? throwOnCall;
  bool completed = false;

  @override
  Future<void> call({
    required String url,
    required String publishableKey,
  }) async {
    if (throwOnCall != null) throw throwOnCall!;
    calls.add((url: url, key: publishableKey));
    completed = true;
  }
}

AppConfig _validConfig({bool cloudSync = true}) => AppConfig(
  supabaseUrl: 'https://abcdefghijkl.supabase.co',
  supabasePublishableKey: 'sb_publishable_abcdefghijklmnopqrstuvwxyz012345-_',
  enableCloudSync: cloudSync,
  enableMl: false,
  enableDemo: false,
);

void main() {
  group('buildCloudGateway — decision table', () {
    test('missing config yields a GuestCloudGateway (cloudNotConfigured)', () {
      final gateway = buildCloudGateway(
        const AppConfig(
          supabaseUrl: '',
          supabasePublishableKey: '',
          enableCloudSync: false,
          enableMl: false,
          enableDemo: false,
        ),
      );

      expect(gateway, isA<GuestCloudGateway>());
      expect(gateway.status, CloudStatus.cloudNotConfigured);
      expect(gateway.statusReason, 'url_missing');
      expect(gateway.isCloudLive, isFalse);
    });

    test(
      'valid config + ENABLE_CLOUD_SYNC=false yields cloudDisabled guest',
      () {
        final gateway = buildCloudGateway(_validConfig(cloudSync: false));

        expect(gateway, isA<GuestCloudGateway>());
        expect(gateway.status, CloudStatus.cloudDisabled);
        expect(gateway.isCloudLive, isFalse);
      },
    );

    test('valid config + cloud sync enabled yields SupabaseCloudGateway', () {
      final gateway = buildCloudGateway(_validConfig());

      expect(gateway, isA<SupabaseCloudGateway>());
      expect(gateway.status, CloudStatus.cloudConfigured);
    });

    test('an admin key never produces a Supabase-backed gateway', () {
      final gateway = buildCloudGateway(
        AppConfig(
          supabaseUrl: 'https://abcdefghijkl.supabase.co',
          supabasePublishableKey: 'sb_secret_should_never_load',
          enableCloudSync: true,
          enableMl: false,
          enableDemo: false,
        ),
      );

      expect(gateway, isA<GuestCloudGateway>());
      expect(gateway.status, CloudStatus.cloudNotConfigured);
      expect(gateway.statusReason, 'key_rejected_secret_key');
    });
  });

  group('GuestCloudGateway', () {
    test('initialize() is a safe no-op that keeps the guest state', () async {
      final gateway = GuestCloudGateway(
        status: CloudStatus.cloudNotConfigured,
        statusReason: 'url_missing',
      );

      await gateway.initialize();

      expect(gateway.status, CloudStatus.cloudNotConfigured);
      expect(gateway.isCloudLive, isFalse);
      expect(gateway.isAuthenticated, isFalse);
    });
  });

  group('SupabaseCloudGateway', () {
    test('initialize() calls the initializer exactly once with raw config', () async {
      final recorder = _RecordingInitializer();
      final gateway = SupabaseCloudGateway(
        config: _validConfig(),
        initializer: recorder,
      );

      expect(gateway.status, CloudStatus.cloudConfigured);
      expect(gateway.isCloudLive, isFalse);

      await gateway.initialize();

      expect(recorder.calls, hasLength(1));
      expect(recorder.calls.single.url, 'https://abcdefghijkl.supabase.co');
      expect(recorder.calls.single.key, startsWith('sb_publishable_'));
      expect(gateway.status, CloudStatus.cloudInitialized);
      expect(gateway.isCloudLive, isTrue);
      // Phase 00 ships no sign-in flow: a fresh client is never authenticated.
      expect(gateway.isAuthenticated, isFalse);
    });

    test('initialize() is idempotent — no repeated network setup', () async {
      final recorder = _RecordingInitializer();
      final gateway = SupabaseCloudGateway(
        config: _validConfig(),
        initializer: recorder,
      );

      await gateway.initialize();
      await gateway.initialize();

      expect(recorder.calls, hasLength(1));
    });

    test('does not initialize when cloud sync is disabled', () async {
      final recorder = _RecordingInitializer();
      final gateway = SupabaseCloudGateway(
        config: _validConfig(cloudSync: false),
        initializer: recorder,
      );

      await gateway.initialize();

      expect(recorder.calls, isEmpty);
      expect(gateway.status, CloudStatus.cloudDisabled);
      expect(gateway.isCloudLive, isFalse);
    });

    test(
      'initialization failure degrades to cloudError, never throws',
      () async {
        final recorder = _RecordingInitializer()
          ..throwOnCall = Exception('boom');
        final gateway = SupabaseCloudGateway(
          config: _validConfig(),
          initializer: recorder,
        );

        await expectLater(gateway.initialize(), completes);

        expect(gateway.status, CloudStatus.cloudError);
        expect(gateway.statusReason, 'initialize_failed');
        expect(gateway.isCloudLive, isFalse);
        // The failure reason must not echo the raw exception (could carry the
        // project URL / headers).
        expect(gateway.statusReason, isNot(contains('boom')));
        expect(gateway.statusReason, isNot(contains('abcdefghijkl')));
      },
    );

    test('a re-evaluated config can no longer be initialized', () async {
      final recorder = _RecordingInitializer();
      final gateway = SupabaseCloudGateway(
        config: AppConfig(
          supabaseUrl: 'https://abcdefghijkl.supabase.co',
          supabasePublishableKey: 'sb_secret_rejected_later',
          enableCloudSync: true,
          enableMl: false,
          enableDemo: false,
        ),
        initializer: recorder,
      );

      await gateway.initialize();

      expect(recorder.calls, isEmpty);
      expect(gateway.status, CloudStatus.cloudNotConfigured);
      expect(gateway.statusReason, 'key_rejected_secret_key');
    });
  });
}
