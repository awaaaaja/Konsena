import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:konsena_ai/features/about/presentation/about_page.dart';

void main() {
  testWidgets('About shows the four configured models as unavailable', (
    tester,
  ) async {
    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: _ModelCatalogBundle(),
        child: const MaterialApp(home: AboutPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Analisis AI belum tersedia.'), findsOneWidget);

    for (final name in [
      'Consent NLI',
      'ConsentGap 5 kelas',
      'Dark Pattern',
      'Privacy Classifier',
    ]) {
      expect(find.textContaining(name), findsOneWidget);
    }
  });
}

class _ModelCatalogBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    if (key != 'assets/models/catalog.json') {
      throw FlutterError('Unexpected asset request: $key');
    }
    final bytes = utf8.encode('''
      {
        "schemaVersion": 1,
        "models": [
          {"name": "Consent NLI", "reason": "Not validated."},
          {"name": "ConsentGap 5 kelas", "reason": "Demo only."},
          {"name": "Dark Pattern", "reason": "Not validated."},
          {"name": "Privacy Classifier", "reason": "Experiment only."}
        ]
      }
      ''');
    return ByteData.view(Uint8List.fromList(bytes).buffer);
  }
}
