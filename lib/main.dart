import 'package:flutter/material.dart';

import 'app/dependencies.dart';
import 'app/konsena_app.dart';
import 'core/supabase/cloud_gateway.dart';

/// KONSENA AI entry point.
///
/// Guest-first and offline-first: no `dart-define` is required for the app to
/// start. When `SUPABASE_URL` / `SUPABASE_PUBLISHABLE_KEY` are absent or
/// invalid the cloud layer resolves to
/// `cloudNotConfigured`/`cloudDisabled` and the guest experience is unchanged.
/// Supabase is initialized only for a valid configuration (PRD §3.3, §13).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Never throws on missing/invalid environment configuration.
  await setupDependencies();

  runApp(KonsenaApp(cloudGateway: getIt<CloudGateway>()));
}
