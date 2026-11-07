import 'package:flutter_test/flutter_test.dart';
import 'package:konsena_ai/app/navigation/route_registry.dart';

void main() {
  test('registry contains exactly the canonical 40 IDs in order', () {
    expect(RouteRegistry.screens, hasLength(40));
    expect(
      RouteRegistry.screens.map((screen) => screen.id.code).toList(),
      List<String>.generate(
        40,
        (index) => 'S${index.toString().padLeft(2, '0')}',
      ),
    );
    expect(RouteRegistry.byId, hasLength(40));
    expect(
      RouteRegistry.screens.map((screen) => screen.path).toSet(),
      hasLength(40),
    );
    expect(
      RouteRegistry.screens.where((screen) => screen.path == '/account'),
      isEmpty,
    );
  });

  test(
    'five canonical tabs have exact roots and `/account` is not a screen',
    () {
      expect(
        RouteRegistry.screens
            .where((screen) => screen.tab != null)
            .map((screen) => screen.path)
            .toList(),
        ['/home', '/scan', '/history', '/profile', '/audit/new'],
      );
      expect(
        RouteRegistry.screens
            .where((screen) => screen.id == ScreenId.s04)
            .single
            .tab,
        isNull,
      );
    },
  );

  test('required route params reject empty, unsafe and overlong values', () {
    final package = RouteRegistry.get(ScreenId.s05);
    expect(
      RouteRegistry.validateParameters(package, {'package': 'com.example.app'}),
      isNull,
    );
    expect(
      RouteRegistry.validateParameters(package, {'package': ''}),
      isNotNull,
    );
    expect(
      RouteRegistry.validateParameters(package, {'package': '../escape'}),
      isNotNull,
    );
    expect(
      RouteRegistry.validateParameters(package, {'package': 'x' * 201}),
      isNotNull,
    );

    final evidence = RouteRegistry.get(ScreenId.s16);
    expect(
      RouteRegistry.validateParameters(evidence, {
        'id': 'draft_1',
        'evidenceId': 'ev_1',
      }),
      isNull,
    );
    expect(
      RouteRegistry.validateParameters(evidence, {
        'id': 'draft/1',
        'evidenceId': 'ev_1',
      }),
      isNotNull,
    );
  });
}
