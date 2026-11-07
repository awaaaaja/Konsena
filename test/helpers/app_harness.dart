import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:konsena_ai/app/konsena_app.dart';
import 'package:konsena_ai/core/config/cloud_status.dart';
import 'package:konsena_ai/core/journey/journey_store.dart';
import 'package:konsena_ai/core/supabase/guest_cloud_gateway.dart';
import 'package:konsena_ai/features/home/domain/home_summary_repository.dart';

/// Loads declared application fonts instead of Flutter test's default Ahem
/// glyphs before capturing visual goldens.
Future<void> loadAppFonts() async {
  final manifest = jsonDecode(
    await rootBundle.loadString('FontManifest.json'),
  ) as List<dynamic>;
  for (final entry in manifest.cast<Map<String, dynamic>>()) {
    final loader = FontLoader(entry['family'] as String);
    for (final font
        in (entry['fonts'] as List<dynamic>).cast<Map<String, dynamic>>()) {
      final asset = font['asset'] as String;
      loader.addFont(rootBundle.load(asset));
    }
    await loader.load();
  }
}

/// Shared harness for Phase 01A widget tests.
///
/// Every test drives the real app widget (`KonsenaApp`) with injected,
/// deterministic dependencies — no platform channels, no network, no
/// SharedPreferences plugin.
GuestCloudGateway guestGateway() =>
    GuestCloudGateway(status: CloudStatus.cloudNotConfigured);

/// Builds the app around a router that is disposed with the test.
Future<void> pumpKonsena(
  WidgetTester tester, {
  required JourneyStore journeyStore,
  HomeSummaryRepository? summaryRepository,
}) {
  return tester.pumpWidget(
    KonsenaApp(
      cloudGateway: guestGateway(),
      journeyStore: journeyStore,
      summaryRepository: summaryRepository,
    ),
  );
}

/// Pumps a bounded number of frames.
///
/// Splash's loading indicator animates while `loading`; `pumpAndSettle`
/// would never settle on that screen, so tests advance frames explicitly
/// until the route change (or a settled screen) is reached.
Future<void> pumpFrames(
  WidgetTester tester, {
  int frames = 15,
  Duration step = const Duration(milliseconds: 80),
}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(step);
  }
}

/// Convenience: pump the app, advance past splash routing, then settle.
Future<void> pumpApp(
  WidgetTester tester, {
  required JourneyStore store,
  HomeSummaryRepository? summaryRepository,
}) async {
  await pumpKonsena(
    tester,
    journeyStore: store,
    summaryRepository: summaryRepository,
  );
  await tester.pump();
  await pumpFrames(tester, frames: 8);
  await tester.pumpAndSettle();
}

/// Resizes the test surface to a logical size (1 device pixel per logical
/// pixel) and restores the previous size when the test ends.
void setSurfaceSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Applies a system text scale (e.g. 2.0 = 200%) and restores it afterwards.
void setTextScale(WidgetTester tester, double factor) {
  tester.platformDispatcher.textScaleFactorTestValue = factor;
  addTearDown(() => tester.platformDispatcher.clearTextScaleFactorTestValue());
}
