import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:konsena_ai/core/journey/journey_store.dart';
import 'package:konsena_ai/app/navigation/konsena_tab_shell.dart';
import 'package:konsena_ai/features/audit/presentation/new_audit_page.dart';
import 'package:konsena_ai/features/history/presentation/history_page.dart';
import 'package:konsena_ai/features/onboarding/presentation/onboarding_page.dart';
import 'package:konsena_ai/features/profile/presentation/profile_page.dart';
import 'package:konsena_ai/features/scan/presentation/scan_hub_page.dart';
import 'package:konsena_ai/features/splash/presentation/splash_page.dart';

import '../helpers/app_harness.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets('S01 onboarding baseline at 393x852', (tester) async {
    setSurfaceSize(tester, const Size(393, 852));
    await pumpApp(tester, store: InMemoryJourneyStore());
    await expectLater(
      find.byType(OnboardingPage),
      matchesGoldenFile('goldens/s01_onboarding_393x852.png'),
    );
  });

  testWidgets('S03 dashboard baseline at 393x852', (tester) async {
    setSurfaceSize(tester, const Size(393, 852));
    await pumpApp(
      tester,
      store: InMemoryJourneyStore(JourneySnapshot.completed()),
    );
    await expectLater(
      find.byType(KonsenaTabShell),
      matchesGoldenFile('goldens/s03_dashboard_393x852.png'),
    );
  });

  testWidgets('S00 splash at 393x852', (tester) async {
    setSurfaceSize(tester, const Size(393, 852));
    await pumpKonsena(tester, journeyStore: _DeferredJourneyStore());
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.byType(SplashScreen), findsOneWidget);
    await expectLater(
      find.byType(SplashScreen),
      matchesGoldenFile('goldens/s00_splash_393x852.png'),
    );
  });

  testWidgets('five tabs, guest profile, S24 and S06 at 393x852', (
    tester,
  ) async {
    setSurfaceSize(tester, const Size(393, 852));
    await pumpApp(
      tester,
      store: InMemoryJourneyStore(JourneySnapshot.completed()),
    );
    await expectLater(
      find.byType(KonsenaTabShell),
      matchesGoldenFile('goldens/tab_beranda_393x852.png'),
    );

    const cases = [
      ('Audit Baru', 'goldens/tab_audit_baru_393x852.png', NewAuditPage),
      ('Pindai', 'goldens/tab_pindai_393x852.png', ScanHubPage),
      ('Riwayat', 'goldens/tab_riwayat_393x852.png', HistoryPage),
      ('Profil', 'goldens/tab_profil_393x852.png', ProfilePage),
    ];
    for (final (label, golden, pageType) in cases) {
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();
      expect(find.byType(pageType), findsOneWidget);
      await expectLater(
        find.byType(KonsenaTabShell),
        matchesGoldenFile(golden),
      );
    }
  });

  testWidgets('S03 at 320dp and 200% text scale', (tester) async {
    setSurfaceSize(tester, const Size(320, 800));
    setTextScale(tester, 2);
    await pumpApp(
      tester,
      store: InMemoryJourneyStore(JourneySnapshot.completed()),
    );
    await expectLater(
      find.byType(KonsenaTabShell),
      matchesGoldenFile('goldens/s03_dashboard_320_200pct.png'),
    );
  });

  testWidgets('S03 tablet at 768x1024', (tester) async {
    setSurfaceSize(tester, const Size(768, 1024));
    await pumpApp(
      tester,
      store: InMemoryJourneyStore(JourneySnapshot.completed()),
    );
    await expectLater(
      find.byType(KonsenaTabShell),
      matchesGoldenFile('goldens/s03_dashboard_768x1024.png'),
    );
  });
}

class _DeferredJourneyStore implements JourneyStore {
  final Completer<JourneySnapshot> _loaded = Completer<JourneySnapshot>();

  @override
  Future<JourneySnapshot> load() => _loaded.future;

  @override
  Future<void> setAnalyticsOptIn(bool value) async {}

  @override
  Future<void> setCloudOptIn(bool value) async {}

  @override
  Future<void> setOnboardingSeen() async {}

  @override
  Future<void> setPrivacySetupSeen({required bool cloudOptIn}) async {}
}
