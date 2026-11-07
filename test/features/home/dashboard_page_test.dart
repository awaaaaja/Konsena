import 'package:flutter_test/flutter_test.dart';
import 'package:konsena_ai/core/journey/journey_store.dart';
import 'package:konsena_ai/features/home/domain/home_summary_repository.dart';
import 'package:konsena_ai/features/home/presentation/dashboard_page.dart';
import 'package:konsena_ai/features/audit/presentation/new_audit_page.dart';

import '../../helpers/app_harness.dart';

class _Summary implements HomeSummaryRepository {
  _Summary(this.value);
  final HomeSummary value;
  @override
  Future<HomeSummary> load() async => value;
}

void main() {
  testWidgets(
    'empty dashboard displays repository-backed zeros without demo labels',
    (tester) async {
      await pumpApp(
        tester,
        store: InMemoryJourneyStore(JourneySnapshot.completed()),
      );
      expect(find.byType(DashboardPage), findsOneWidget);
      expect(find.text('0'), findsNWidgets(2));
      expect(find.textContaining('DEMO'), findsNothing);
      expect(find.textContaining('Sesi contoh'), findsNothing);
      expect(find.textContaining('Analisis contoh'), findsNothing);
    },
  );

  testWidgets('summary values are supplied by the repository', (tester) async {
    await pumpApp(
      tester,
      store: InMemoryJourneyStore(JourneySnapshot.completed()),
      summaryRepository: _Summary(
        const HomeSummary(auditCount: 7, findingCount: 12),
      ),
    );
    expect(find.text('7'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
  });

  testWidgets('Mulai Audit opens the S24 draft wizard', (tester) async {
    await pumpApp(
      tester,
      store: InMemoryJourneyStore(JourneySnapshot.completed()),
    );
    await tester.tap(find.text('Mulai Audit'));
    await tester.pumpAndSettle();
    expect(find.byType(NewAuditPage), findsOneWidget);
    expect(find.text('Mulai dari sumber yang kamu punya'), findsOneWidget);
  });
}
