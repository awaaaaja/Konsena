import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:konsena_ai/app/dependencies.dart';
import 'package:konsena_ai/app/konsena_app.dart';
import 'package:konsena_ai/core/config/app_config.dart';
import 'package:konsena_ai/core/config/cloud_status.dart';
import 'package:konsena_ai/core/supabase/cloud_gateway.dart';
import 'package:konsena_ai/core/supabase/guest_cloud_gateway.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Phase 00 startup contract.
///
/// Two mandatory scenarios:
///  1. no `--dart-define` at all -> app boots as guest, no crash, cloud off;
///  2. valid config -> the Supabase gateway initializes through the single
///     network seam, and startup performs **no** storage/upload/auth request.
class _RecordingInitializer implements SupabaseInitializer {
  int calls = 0;
  String? seenUrl;
  String? seenKey;

  @override
  Future<void> call({
    required String url,
    required String publishableKey,
  }) async {
    calls += 1;
    seenUrl = url;
    seenKey = publishableKey;
  }
}

void main() {
  tearDown(() async {
    if (getIt.isRegistered<AppConfig>() || getIt.isRegistered<CloudGateway>()) {
      await getIt.reset();
    }
  });

  group('Startup without any environment configuration', () {
    test(
      'setupDependencies resolves guest state instead of throwing',
      () async {
        await setupDependencies(
          config: const AppConfig(
            supabaseUrl: '',
            supabasePublishableKey: '',
            enableCloudSync: false,
            enableMl: false,
            enableDemo: false,
          ),
        );

        final gateway = getIt<CloudGateway>();

        expect(gateway.status, CloudStatus.cloudNotConfigured);
        expect(gateway.isCloudLive, isFalse);
        expect(gateway.isAuthenticated, isFalse);
        expect(gateway, isA<GuestCloudGateway>());
      },
    );

    testWidgets('boots as guest with cloud feature disabled', (tester) async {
      await setupDependencies(
        config: const AppConfig(
          supabaseUrl: '',
          supabasePublishableKey: '',
          enableCloudSync: false,
          enableMl: false,
          enableDemo: false,
        ),
      );

      await tester.pumpWidget(KonsenaApp(cloudGateway: getIt<CloudGateway>()));
      await tester.pumpAndSettle();

      // No crash: the guest shell rendered.
      expect(tester.takeException(), isNull);
      expect(find.text('KONSENA AI'), findsWidgets);
      // Status copy is rendered by both the status card and the detail block.
      expect(find.text('Mode tamu — cloud belum dikonfigurasi'), findsWidgets);
      expect(find.textContaining('Tamu (offline)'), findsWidgets);
      expect(find.text('Cloud tidak aktif'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });

    testWidgets(
      'ENABLE_CLOUD_SYNC=false with valid keys still boots as guest',
      (tester) async {
        await setupDependencies(
          config: const AppConfig(
            supabaseUrl: 'https://abcdefghijkl.supabase.co',
            supabasePublishableKey:
                'sb_publishable_abcdefghijklmnopqrstuvwxyz012345-_',
            enableCloudSync: false,
            enableMl: false,
            enableDemo: false,
          ),
        );

        await tester.pumpWidget(
          KonsenaApp(cloudGateway: getIt<CloudGateway>()),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(getIt<CloudGateway>().status, CloudStatus.cloudDisabled);
        expect(
          find.text('Mode tamu — sinkronisasi cloud nonaktif'),
          findsWidgets,
        );
        expect(find.byIcon(Icons.cloud_off), findsOneWidget);
      },
    );
  });

  group('Startup with a valid configuration', () {
    test(
      'initializes the Supabase gateway through exactly one network seam',
      () async {
        final recorder = _RecordingInitializer();

        await setupDependencies(
          config: const AppConfig(
            supabaseUrl: 'https://abcdefghijkl.supabase.co',
            supabasePublishableKey:
                'sb_publishable_abcdefghijklmnopqrstuvwxyz012345-_',
            enableCloudSync: true,
            enableMl: false,
            enableDemo: false,
          ),
          initializer: recorder,
        );

        final gateway = getIt<CloudGateway>();

        expect(gateway.status, CloudStatus.cloudInitialized);
        expect(gateway.isCloudLive, isTrue);
        expect(recorder.calls, 1);
        expect(recorder.seenUrl, 'https://abcdefghijkl.supabase.co');
        expect(recorder.seenKey, startsWith('sb_publishable_'));

        // No Supabase client was constructed by the app itself, therefore no
        // storage upload / auth request / REST call could have been issued.
        expect(() => Supabase.instance, throwsA(anything));
      },
    );

    testWidgets('renders the connected state without performing any write', (
      tester,
    ) async {
      final recorder = _RecordingInitializer();

      await setupDependencies(
        config: const AppConfig(
          supabaseUrl: 'https://abcdefghijkl.supabase.co',
          supabasePublishableKey:
              'sb_publishable_abcdefghijklmnopqrstuvwxyz012345-_',
          enableCloudSync: true,
          enableMl: false,
          enableDemo: false,
        ),
        initializer: recorder,
      );

      await tester.pumpWidget(KonsenaApp(cloudGateway: getIt<CloudGateway>()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // Status copy is rendered by both the status card and the detail block.
      expect(find.text('Cloud terhubung (sinkronisasi opt-in)'), findsWidgets);
      expect(find.byIcon(Icons.cloud_done), findsOneWidget);
      // Sign-in is a Phase 07 opt-in: still a guest after startup.
      expect(find.textContaining('Tamu (offline)'), findsWidgets);
      // Startup still only ever hit the single initializer seam.
      expect(recorder.calls, 1);
    });
  });
}
