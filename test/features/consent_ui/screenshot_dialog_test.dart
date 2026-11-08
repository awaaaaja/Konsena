import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:konsena_ai/features/consent_ui/domain/screenshot_review.dart';
import 'package:konsena_ai/features/consent_ui/presentation/screenshot_rect_dialog.dart';

void main() {
  testWidgets(
    'focused crop dialog can apply and dismiss without disposed-controller errors',
    (tester) async {
      RectEditValue? saved;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  saved = await showDialog<RectEditValue>(
                    context: context,
                    builder: (_) => const ScreenshotRectDialog(
                      initialRect: SourceRect(0, 0, 1, 1),
                    ),
                  );
                },
                child: const Text('Crop'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Crop'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('rect-field-2')), '0.8');
      await tester.tap(find.text('Terapkan'));
      await tester.pumpAndSettle();
      expect(saved!.rect.width, .8);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Crop'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('rect-field-2')), '2');
      await tester.tap(find.text('Terapkan'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Gunakan koordinat valid'), findsOneWidget);
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
