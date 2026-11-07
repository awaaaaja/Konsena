import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:konsena_ai/core/journey/journey_store.dart';
import 'package:konsena_ai/features/history/presentation/history_page.dart';

import '../helpers/app_harness.dart';

void main() {
  testWidgets(
    'large-text tab destinations expose named 48dp semantic actions',
    (tester) async {
      setSurfaceSize(tester, const Size(320, 800));
      setTextScale(tester, 2);
      final semantics = tester.ensureSemantics();
      await pumpApp(
        tester,
        store: InMemoryJourneyStore(JourneySnapshot.completed()),
      );

      final historyAction = find.bySemanticsLabel('Riwayat');
      expect(historyAction, findsOneWidget);
      final target = tester.getSize(historyAction);
      expect(target.width, greaterThanOrEqualTo(48));
      expect(target.height, greaterThanOrEqualTo(48));

      await tester.tap(historyAction);
      await tester.pumpAndSettle();
      expect(find.byType(HistoryPage), findsOneWidget);
      semantics.dispose();
    },
  );
}
