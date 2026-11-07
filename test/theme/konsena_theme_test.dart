import 'package:flutter_test/flutter_test.dart';
import 'package:konsena_ai/theme/konsena_colors.dart';
import 'package:konsena_ai/theme/konsena_theme.dart';

void main() {
  test('theme uses approved palette and Plus Jakarta Sans', () {
    final theme = KonsenaTheme.light();
    expect(theme.colorScheme.primary, KonsenaColors.royalViolet);
    expect(theme.scaffoldBackgroundColor, KonsenaColors.backgroundPage);
    expect(theme.textTheme.bodyMedium?.fontFamily, 'PlusJakartaSans');
  });
}
