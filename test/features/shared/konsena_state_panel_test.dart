import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:konsena_ai/features/shared/widgets/konsena_state_panel.dart';

void main() {
  testWidgets('each state has distinct domain copy and accessible heading', (
    tester,
  ) async {
    for (final kind in KonsenaStateKind.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KonsenaStatePanel(
              kind: kind,
              title: 'Judul ${kind.name}',
              message: 'Alasan ${kind.name}',
            ),
          ),
        ),
      );
      expect(find.text('Judul ${kind.name}'), findsOneWidget);
      expect(find.text('Alasan ${kind.name}'), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.header == true,
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('recovery action is actionable and meets 48dp minimum', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KonsenaStatePanel(
            kind: KonsenaStateKind.error,
            title: 'Gagal memuat riwayat',
            message: 'Data lokal belum dapat dibaca.',
            actionLabel: 'Coba lagi',
            onAction: () => tapped = true,
          ),
        ),
      ),
    );

    final button = tester.getSize(find.byType(OutlinedButton));
    expect(button.height, greaterThanOrEqualTo(48));
    await tester.tap(find.text('Coba lagi'));
    expect(tapped, isTrue);
  });
}
