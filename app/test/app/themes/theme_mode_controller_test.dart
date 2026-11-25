import 'package:biluca_financas/app/themes/theme_mode_controller.dart';
import 'package:biluca_financas/core/preferences/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<PreferencesService> loadService([
    Map<String, Object> values = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(values);
    return PreferencesService.load();
  }

  test('starts with the stored appearance mode', () async {
    final controller = ThemeModeController.fromPreferences(
      await loadService({PreferencesService.themeModeKey: 'light'}),
    );

    expect(controller.value, ThemeMode.light);
  });

  test('selects and persists a new appearance mode', () async {
    final controller = ThemeModeController.fromPreferences(
      await loadService(),
    );

    await controller.select(ThemeMode.dark);

    expect(controller.value, ThemeMode.dark);
    expect((await PreferencesService.load()).themeMode, ThemeMode.dark);
  });
}
