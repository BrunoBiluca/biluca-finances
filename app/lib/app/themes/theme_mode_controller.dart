import 'package:biluca_financas/core/preferences/preferences_service.dart';
import 'package:flutter/material.dart';

/// Holds the appearance mode chosen by the person using the application.
class ThemeModeController extends ValueNotifier<ThemeMode> {
  final PreferencesService preferences;

  ThemeModeController.fromPreferences(this.preferences)
      : super(preferences.themeMode);

  Future<void> select(ThemeMode mode) async {
    if (value == mode) return;
    value = mode;
    await preferences.setThemeMode(mode);
  }
}
