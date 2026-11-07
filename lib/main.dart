import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/dependencies.dart';
import 'app/konsena_app.dart';
import 'core/journey/journey_store.dart';
import 'core/supabase/cloud_gateway.dart';
import 'data/local/app_database.dart';
import 'data/audit/audit_repository.dart';
import 'data/audit/local_source_file_store.dart';
import 'data/audit/local_data_cipher.dart';

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

  // Determine whether a secure key may be created before opening SQLite (which
  // itself creates the database file). Never replace a missing key when local
  // encrypted data may already exist.
  final supportDirectory = await getApplicationSupportDirectory();
  final existingDatabase = File(
    p.join(supportDirectory.path, 'database', 'konsena.sqlite'),
  );
  final sourceDirectory = Directory(
    p.join(supportDirectory.path, 'audit_sources'),
  );
  var hasExistingSourceFiles = false;
  if (await sourceDirectory.exists()) {
    await for (final entry in sourceDirectory.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entry is File && entry.path.endsWith('.source')) {
        hasExistingSourceFiles = true;
        break;
      }
    }
  }
  final keyProvider = SecureStorageEncryptionKeyProvider(
    allowCreate: !await existingDatabase.exists() && !hasExistingSourceFiles,
  );
  // Resolve key presence before recovery can mutate or remove any file.
  await keyProvider.getOrCreateKey();
  final database = await AppDatabase.openDefault();
  final cipher = LocalDataCipher(keyProvider: keyProvider);
  final sourceFiles = await LocalSourceFileStore.openDefault(cipher: cipher);
  final audits = AuditRepository(
    database: database,
    files: sourceFiles,
    cipher: cipher,
  );
  await audits.recoverFileLifecycle();
  final journeyStore = await _createJourneyStore();
  final journey = await journeyStore.load();
  await audits.migratePrivacyPreferences(
    cloudOptIn: journey.cloudOptIn,
    analyticsOptIn: journey.analyticsOptIn,
  );

  runApp(
    KonsenaApp(
      cloudGateway: getIt<CloudGateway>(),
      journeyStore: journeyStore,
      auditRepository: audits,
    ),
  );
}

/// On-device journey flags.
///
/// If platform storage is unavailable the app falls back to an in-memory
/// store (treated as a first run). It never blocks startup and never
/// fabricates a completed journey.
Future<JourneyStore> _createJourneyStore() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesJourneyStore(prefs);
  } on Object {
    return InMemoryJourneyStore(JourneySnapshot.firstRun());
  }
}
