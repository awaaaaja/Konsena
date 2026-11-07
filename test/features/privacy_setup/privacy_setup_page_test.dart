import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:konsena_ai/features/privacy_setup/presentation/privacy_setup_page.dart';
import 'package:konsena_ai/features/home/presentation/dashboard_page.dart';
import 'package:konsena_ai/features/shared/widgets/konsena_buttons.dart';
import 'package:konsena_ai/core/config/cloud_status.dart';
import 'package:konsena_ai/core/supabase/guest_cloud_gateway.dart';
import 'package:konsena_ai/app/konsena_app.dart';
import 'package:konsena_ai/core/journey/journey_store.dart';

void main() {
  testWidgets('consents start separately off and save local guest choices', (
    tester,
  ) async {
    final store = InMemoryJourneyStore(
      const JourneySnapshot(onboardingSeen: true),
    );
    await tester.pumpWidget(
      KonsenaApp(
        cloudGateway: GuestCloudGateway(status: CloudStatus.cloudNotConfigured),
        journeyStore: store,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.byType(PrivacySetupPage), findsOneWidget);
    expect(find.byType(Switch), findsNWidgets(2));
    expect(
      tester.widgetList<Switch>(find.byType(Switch)).every((s) => !s.value),
      isTrue,
    );
    expect(find.textContaining('Belum diminta di halaman ini'), findsOneWidget);
    await tester.ensureVisible(find.byType(KonsenaPrimaryButton));
    await tester.tap(find.byType(KonsenaPrimaryButton));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardPage), findsOneWidget);
    expect(store.snapshot.privacySetupSeen, isTrue);
    expect(store.snapshot.cloudOptIn, isFalse);
    expect(store.snapshot.analyticsOptIn, isFalse);
  });

  test('Android manifest does not request camera permission in Phase 01A', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    expect(manifest, isNot(contains('android.permission.CAMERA')));
  });
}
