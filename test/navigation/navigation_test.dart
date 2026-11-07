import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:konsena_ai/app/app_router.dart';
import 'package:konsena_ai/app/konsena_app.dart';
import 'package:konsena_ai/app/navigation/audit_draft_store.dart';
import 'package:konsena_ai/app/navigation/konsena_tab_shell.dart';
import 'package:konsena_ai/app/navigation/route_registry.dart';
import 'package:konsena_ai/core/config/cloud_status.dart';
import 'package:konsena_ai/core/journey/journey_store.dart';
import 'package:konsena_ai/core/supabase/guest_cloud_gateway.dart';
import 'package:konsena_ai/features/audit/presentation/new_audit_page.dart';
import 'package:konsena_ai/features/about/presentation/about_page.dart';
import 'package:konsena_ai/features/history/presentation/history_page.dart';
import 'package:konsena_ai/features/home/presentation/dashboard_page.dart';
import 'package:konsena_ai/features/navigation/presentation/route_screen_page.dart';
import 'package:konsena_ai/features/onboarding/presentation/onboarding_page.dart';
import 'package:konsena_ai/features/privacy_setup/presentation/privacy_setup_page.dart';
import 'package:konsena_ai/features/profile/presentation/profile_page.dart';
import 'package:konsena_ai/features/scan/presentation/scan_hub_page.dart';
import 'package:konsena_ai/features/settings/presentation/settings_page.dart';

GoRouter _router({AuditDraftStore? drafts, String initialLocation = '/home'}) =>
    createAppRouter(
      journeyStore: InMemoryJourneyStore(JourneySnapshot.completed()),
      draftStore: drafts,
      initialLocation: initialLocation,
    );

Widget _app(GoRouter router, {AuditDraftStore? drafts}) => KonsenaApp(
  cloudGateway: GuestCloudGateway(status: CloudStatus.cloudNotConfigured),
  journeyStore: InMemoryJourneyStore(JourneySnapshot.completed()),
  draftStore: drafts,
  router: router,
);

String _samplePath(ScreenSpec spec, String auditId) {
  final replacements = <String, String>{
    'package': 'com.example.app',
    'id': auditId,
    'docId': 'doc_1',
    'evidenceId': 'evidence_1',
    'actionId': 'action_1',
    'auditId': auditId,
    'itemId': 'item_1',
  };
  return spec.path.replaceAllMapped(
    RegExp(r':([A-Za-z][A-Za-z0-9_]*)'),
    (match) => replacements[match.group(1)]!,
  );
}

void main() {
  testWidgets(
    'all canonical route templates resolve to a screen or explicit guard recovery',
    (tester) async {
      final drafts = AuditDraftStore();
      final audit = drafts.create(name: 'Uji navigasi');
      final router = _router(drafts: drafts);
      addTearDown(router.dispose);
      await tester.pumpWidget(_app(router, drafts: drafts));
      await tester.pumpAndSettle();

      for (final spec in RouteRegistry.screens) {
        final path = _samplePath(spec, audit.id);
        router.go(path);
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '${spec.id.code} ${spec.path}',
        );
        // Every entry is either a screen with visible content or a deliberate
        // guard fallback (S22/S37 guest, S00 splash decision).
        expect(
          find.byType(Scaffold),
          findsWidgets,
          reason: '${spec.id.code} rendered no scaffold',
        );
        final expectedPath = switch (spec.id) {
          ScreenId.s00 => '/home', // Completed local journey exits splash.
          ScreenId.s22 || ScreenId.s37 => '/profile', // Guest sync guard.
          _ => path,
        };
        expect(
          router.routeInformationProvider.value.uri.path,
          expectedPath,
          reason: '${spec.id.code} did not resolve to its canonical location',
        );
        final rendered = switch (spec.id) {
          ScreenId.s00 => find.byType(DashboardPage),
          ScreenId.s01 => find.byType(OnboardingPage),
          ScreenId.s02 => find.byType(PrivacySetupPage),
          ScreenId.s03 => find.byType(DashboardPage),
          ScreenId.s06 => find.byType(ScanHubPage),
          ScreenId.s19 => find.byType(HistoryPage),
          ScreenId.s20 => find.byType(SettingsPage),
          ScreenId.s21 ||
          ScreenId.s22 ||
          ScreenId.s37 => find.byType(ProfilePage),
          ScreenId.s23 => find.byType(AboutPage),
          ScreenId.s24 => find.byType(NewAuditPage),
          ScreenId.s16 => find.text('Bukti belum tersedia'),
          _ => find.byType(RouteScreenPage),
        };
        expect(
          rendered,
          findsOneWidget,
          reason: '${spec.id.code} fell through to a non-screen recovery',
        );
      }
      expect(
        router.routeInformationProvider.value.uri.path,
        '/scan/camera/how-to',
      );
    },
  );

  testWidgets('shell presents exactly five Indonesian destinations', (
    tester,
  ) async {
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(router));
    await tester.pumpAndSettle();

    expect(find.byType(KonsenaTabShell), findsOneWidget);
    final nav = find.byType(NavigationBar);
    expect(
      find.descendant(of: nav, matching: find.text('Beranda')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: nav, matching: find.text('Audit Baru')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: nav, matching: find.text('Pindai')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: nav, matching: find.text('Riwayat')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: nav, matching: find.text('Profil')),
      findsOneWidget,
    );
    expect(tester.widget<NavigationBar>(nav).destinations, hasLength(5));
  });

  testWidgets(
    'S24 form survives tab changes and remains a guest-accessible draft',
    (tester) async {
      final router = _router();
      addTearDown(router.dispose);
      await tester.pumpWidget(_app(router));
      await tester.pumpAndSettle();
      router.go('/audit/new');
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('audit-name-field')),
        'Draft yang tidak hilang',
      );

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Profil'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ProfilePage), findsOneWidget);
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Audit Baru'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NewAuditPage), findsOneWidget);
      expect(find.text('Draft yang tidak hilang'), findsOneWidget);
      expect(find.text('Mode tamu — data di perangkat'), findsNothing);
    },
  );

  testWidgets('audit CTA creates a draft and child Back returns to S24', (
    tester,
  ) async {
    final drafts = AuditDraftStore();
    final router = _router(drafts: drafts);
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(router, drafts: drafts));
    await tester.pumpAndSettle();
    router.go('/audit/new');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Gunakan workspace tanpa aplikasi'));
    await tester.tap(find.text('Gunakan workspace tanpa aplikasi'));
    await tester.pumpAndSettle();
    expect(drafts.drafts, hasLength(1));
    expect(find.byType(RouteScreenPage), findsOneWidget);
    expect(find.text('Workspace Audit'), findsWidgets);
    expect(find.text('Draft audit: ${drafts.latest!.id}'), findsOneWidget);
    expect(find.text('Audit tidak ditemukan'), findsNothing);

    router.pop();
    await tester.pumpAndSettle();
    expect(find.byType(NewAuditPage), findsOneWidget);
  });

  testWidgets('S24 can open S04 as a child and keeps audit context', (
    tester,
  ) async {
    final drafts = AuditDraftStore();
    final router = _router(drafts: drafts);
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(router, drafts: drafts));
    await tester.pumpAndSettle();
    router.go('/audit/new');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Buat audit dan pilih aplikasi'));
    await tester.tap(find.text('Buat audit dan pilih aplikasi'));
    await tester.pumpAndSettle();

    expect(find.text('Pilih Aplikasi'), findsWidgets);
    expect(
      find.textContaining('Draft audit: ${drafts.latest!.id}'),
      findsOneWidget,
    );
    router.pop();
    await tester.pumpAndSettle();
    expect(find.byType(NewAuditPage), findsOneWidget);
  });

  testWidgets(
    'Scan hub CTAs lead to document, camera guidance and screenshot routes',
    (tester) async {
      final router = _router(initialLocation: '/scan');
      addTearDown(router.dispose);
      await tester.pumpWidget(_app(router));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dokumen atau teks'));
      await tester.pumpAndSettle();
      expect(find.text('Jenis Dokumen'), findsWidgets);
      router.pop();
      await tester.pumpAndSettle();

      await tester.tap(find.text('LiveScan layar laptop'));
      await tester.pumpAndSettle();
      expect(find.text('Panduan LiveScan'), findsWidgets);
      router.pop();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Screenshot persetujuan'));
      await tester.pumpAndSettle();
      expect(find.text('Impor Screenshot'), findsWidgets);
    },
  );

  testWidgets('unknown URL and missing session have useful recovery', (
    tester,
  ) async {
    final drafts = AuditDraftStore();
    final router = _router(drafts: drafts);
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(router, drafts: drafts));
    await tester.pumpAndSettle();

    router.go('/audit/not_found/sources');
    await tester.pumpAndSettle();
    expect(find.text('Audit tidak ditemukan'), findsOneWidget);
    expect(find.text('Mulai audit baru'), findsOneWidget);

    router.go('/this-route-does-not-exist');
    await tester.pumpAndSettle();
    expect(find.text('Tautan tidak dapat dibuka'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('/account redirects to Profile without creating a screen ID', (
    tester,
  ) async {
    final router = _router(initialLocation: '/account');
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(router));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/profile');
    expect(find.byType(ProfilePage), findsOneWidget);
  });

  testWidgets(
    'guest profile is useful and sync guard returns with explanation',
    (tester) async {
      final router = _router(initialLocation: '/profile');
      addTearDown(router.dispose);
      await tester.pumpWidget(_app(router));
      await tester.pumpAndSettle();
      expect(find.text('Mode tamu — data di perangkat'), findsOneWidget);
      expect(find.text('Kontrol data'), findsOneWidget);
      router.go('/sync');
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/profile');
      expect(find.text('Sinkronisasi belum diaktifkan'), findsOneWidget);
    },
  );

  testWidgets('invalid route params render recovery, not a blank page', (
    tester,
  ) async {
    final drafts = AuditDraftStore();
    final router = _router(drafts: drafts);
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(router, drafts: drafts));
    await tester.pumpAndSettle();
    router.go('/audit/apps/%2E%2E%2Fsecret');
    await tester.pumpAndSettle();
    expect(find.textContaining('Format parameter'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
