import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:konsena_ai/core/journey/journey_store.dart';
import 'package:konsena_ai/features/home/presentation/dashboard_page.dart';

import '../helpers/app_harness.dart';

void main() {
  for (final size in const [
    Size(320, 800),
    Size(393, 852),
    Size(430, 932),
    Size(768, 1024),
  ]) {
    testWidgets('S03 has no layout exception at ${size.width}dp', (
      tester,
    ) async {
      setSurfaceSize(tester, size);
      await pumpApp(
        tester,
        store: InMemoryJourneyStore(JourneySnapshot.completed()),
      );
      expect(find.byType(DashboardPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('S03 remains scrollable and operable at 200% text scale', (
    tester,
  ) async {
    setSurfaceSize(tester, const Size(320, 800));
    setTextScale(tester, 2);
    await pumpApp(
      tester,
      store: InMemoryJourneyStore(JourneySnapshot.completed()),
    );
    expect(find.byType(DashboardPage), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Mulai Audit'));
    expect(find.text('Mulai Audit'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Mulai Audit'));
    await tester.pumpAndSettle();
    expect(find.text('Mulai dari sumber yang kamu punya'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('S24 scrolls above simulated system insets and keyboard', (
    tester,
  ) async {
    setSurfaceSize(tester, const Size(320, 800));
    tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 24);
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(tester.view.resetViewPadding);
    addTearDown(tester.view.resetViewInsets);
    await pumpApp(
      tester,
      store: InMemoryJourneyStore(JourneySnapshot.completed()),
    );
    await tester.tap(find.text('Audit Baru').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('audit-name-field')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Buat audit dan pilih aplikasi'));
    expect(find.text('Buat audit dan pilih aplikasi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
