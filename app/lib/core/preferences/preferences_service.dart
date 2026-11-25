import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Typed access to the preferences persisted with the platform store.
class PreferencesService {
  static const String themeModeKey = 'appearance.theme_mode';
  static const String sidebarCollapsedKey = 'navigation.sidebar_collapsed';
  static const String selectedMonthKey = 'reports.selected_month';
  static const String selectedYearKey = 'reports.selected_year';

  final SharedPreferences preferences;

  const PreferencesService(this.preferences);

  static Future<PreferencesService> load() async {
    return PreferencesService(await SharedPreferences.getInstance());
  }

  ThemeMode get themeMode {
    return switch (preferences.getString(themeModeKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) {
    return preferences.setString(themeModeKey, mode.name);
  }

  bool get sidebarCollapsed =>
      preferences.getBool(sidebarCollapsedKey) ?? false;

  Future<void> setSidebarCollapsed(bool collapsed) {
    return preferences.setBool(sidebarCollapsedKey, collapsed);
  }

  String? get selectedMonth => preferences.getString(selectedMonthKey);

  Future<void> setSelectedMonth(String? month) async {
    if (month == null) {
      await preferences.remove(selectedMonthKey);
      return;
    }
    await preferences.setString(selectedMonthKey, month);
  }

  String? get selectedYear => preferences.getString(selectedYearKey);

  Future<void> setSelectedYear(String? year) async {
    if (year == null) {
      await preferences.remove(selectedYearKey);
      return;
    }
    await preferences.setString(selectedYearKey, year);
  }
}
