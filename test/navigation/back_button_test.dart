import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:konsena_ai/features/shared/widgets/konsena_back_button.dart';

void main() {
  testWidgets(
    'back on a child deep link uses its explicit parent; pushed child pops',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/child',
        routes: [
          GoRoute(
            path: '/parent',
            builder: (context, state) => Scaffold(
              body: TextButton(
                onPressed: () => context.push('/child'),
                child: const Text('Open child'),
              ),
            ),
          ),
          GoRoute(
            path: '/child',
            builder: (context, state) => Scaffold(
              appBar: AppBar(
                leading: const KonsenaBackButton(fallback: '/parent'),
              ),
              body: const Text('Child'),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Kembali'));
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/parent');
      await tester.tap(find.text('Open child'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Kembali'));
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/parent');
    },
  );
}
