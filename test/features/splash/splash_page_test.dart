import 'package:flutter_test/flutter_test.dart';
import 'package:konsena_ai/core/journey/journey_store.dart';
import 'package:konsena_ai/features/onboarding/presentation/onboarding_page.dart';

import '../../helpers/app_harness.dart';

class _FailingStore implements JourneyStore {
  @override
  Future<JourneySnapshot> load() async => throw StateError('private detail');
  @override
  Future<void> setAnalyticsOptIn(bool value) async {}
  @override
  Future<void> setCloudOptIn(bool value) async {}
  @override
  Future<void> setOnboardingSeen() async {}
  @override
  Future<void> setPrivacySetupSeen({required bool cloudOptIn}) async {}
}

void main() {
  testWidgets('first-run splash routes to onboarding', (tester) async {
    await pumpKonsena(tester, journeyStore: InMemoryJourneyStore());
    await tester.pump();
    await pumpFrames(tester, frames: 8);
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'failed local bootstrap offers retry without exposing error text',
    (tester) async {
      await pumpKonsena(tester, journeyStore: _FailingStore());
      await tester.pump();
      await tester.pump();
      expect(find.text('Gagal memulai aplikasi'), findsOneWidget);
      expect(find.text('Coba lagi'), findsOneWidget);
      expect(find.textContaining('private detail'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
