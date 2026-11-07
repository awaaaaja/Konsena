import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:konsena_ai/core/journey/journey_store.dart';
import 'package:konsena_ai/features/onboarding/presentation/onboarding_page.dart';
import 'package:konsena_ai/features/onboarding/presentation/onboarding_slide.dart';
import 'package:konsena_ai/features/privacy_setup/presentation/privacy_setup_page.dart';
import 'package:konsena_ai/features/shared/widgets/konsena_buttons.dart';

import '../../helpers/app_harness.dart';

/// Phase 01A mandatory suite for S01 (this is the path required by the
/// phase gate: `flutter test test/features/onboarding/`).
void main() {
  Future<void> pumpFirstRun(WidgetTester tester, {JourneyStore? store}) async {
    await pumpKonsena(tester, journeyStore: store ?? InMemoryJourneyStore());
    await tester.pump();
  }

  testWidgets('first launch lands on S01 with the mandated headline', (
    tester,
  ) async {
    await pumpFirstRun(tester);
    await pumpFrames(tester, frames: 8);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.text('Ubah Kebijakan Privasi yang Rumit Jadi Mudah Dipahami'),
      findsOneWidget,
    );
    expect(find.text('Lewati'), findsOneWidget);
    expect(find.byType(OnboardingPage), findsOneWidget);
  });

  testWidgets('exactly three slides exist and advance in order', (
    tester,
  ) async {
    await pumpFirstRun(tester);
    await pumpFrames(tester, frames: 8);
    await tester.pumpAndSettle();

    // Three pagination dots (the Stitch reference shows four).
    expect(
      find.descendant(
        of: find.byType(OnboardingDots),
        matching: find.byType(AnimatedContainer),
      ),
      findsNWidgets(3),
    );
    expect(kOnboardingSlides, hasLength(3));

    // Slide 1 → 2 → 3 through the round violet CTA.
    await tester.tap(find.byType(KonsenaRoundCta));
    await tester.pumpAndSettle();
    expect(find.text('Siapkan Kebijakan untuk Ditinjau'), findsOneWidget);

    await tester.tap(find.byType(KonsenaRoundCta));
    await tester.pumpAndSettle();
    expect(
      find.text('Tinjau Bukti Sebelum Menarik Kesimpulan'),
      findsOneWidget,
    );

    // Still on S01 — the last slide does not skip the final continue tap.
    expect(find.byType(OnboardingPage), findsOneWidget);
    expect(find.byType(PrivacySetupPage), findsNothing);
  });

  testWidgets('completing the third slide continues to S02', (tester) async {
    final store = InMemoryJourneyStore();
    await pumpKonsena(tester, journeyStore: store);
    await tester.pump();
    await pumpFrames(tester, frames: 8);
    await tester.pumpAndSettle();

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byType(KonsenaRoundCta));
      await tester.pumpAndSettle();
    }

    expect(find.byType(PrivacySetupPage), findsOneWidget);
    expect(find.byType(OnboardingPage), findsNothing);

    // onboarding_seen is stored locally (PAGE_BY_PAGE S01).
    expect(store.snapshot.onboardingSeen, isTrue);
    // Privacy setup itself is not completed yet — that belongs to S02.
    expect(store.snapshot.privacySetupSeen, isFalse);
  });

  testWidgets('Lewati navigates straight to S02 and marks onboarding seen', (
    tester,
  ) async {
    final store = InMemoryJourneyStore();
    await pumpKonsena(tester, journeyStore: store);
    await tester.pump();
    await pumpFrames(tester, frames: 8);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lewati'));
    await tester.pumpAndSettle();

    expect(find.byType(PrivacySetupPage), findsOneWidget);
    expect(store.snapshot.onboardingSeen, isTrue);
  });

  testWidgets('all interactive targets are at least 48dp', (tester) async {
    final semantics = tester.ensureSemantics();

    await pumpFirstRun(tester);
    await pumpFrames(tester, frames: 8);
    await tester.pumpAndSettle();

    final roundCta = tester.getSize(find.byType(KonsenaRoundCta));
    expect(roundCta.width, greaterThanOrEqualTo(48));
    expect(roundCta.height, greaterThanOrEqualTo(48));

    final skipSize = tester.getSize(
      find.ancestor(of: find.text('Lewati'), matching: find.byType(TextButton)),
    );
    expect(skipSize.height, greaterThanOrEqualTo(48));
    expect(skipSize.width, greaterThanOrEqualTo(48));

    // Round CTA semantics are exposed as a labelled button.
    expect(find.bySemanticsLabel('Selanjutnya, halaman 2'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Lewati onboarding'),
      findsOneWidget,
      reason: 'skip must carry an accessibility label like the reference',
    );
    semantics.dispose();
  });

  testWidgets('no overflow on a 320dp wide screen', (tester) async {
    setSurfaceSize(tester, const Size(320, 640));

    await pumpFirstRun(tester);
    await pumpFrames(tester, frames: 8);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    // And still no overflow while advancing through all three slides.
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byType(KonsenaRoundCta));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    expect(find.byType(PrivacySetupPage), findsOneWidget);
  });

  testWidgets('no overflow at 200% text scale', (tester) async {
    setTextScale(tester, 2.0);

    await pumpFirstRun(tester);
    await pumpFrames(tester, frames: 8);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Lewati'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(PrivacySetupPage), findsOneWidget);
  });
}
