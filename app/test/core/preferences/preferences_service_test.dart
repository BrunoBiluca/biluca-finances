import 'package:biluca_financas/core/preferences/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<PreferencesService> loadService([
    Map<String, Object> initialValues = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(initialValues);
    return PreferencesService.load();
  }

  test('uses the defaults when no preference was stored', () async {
    final service = await loadService();

    expect(service.themeMode, ThemeMode.system);
    expect(service.sidebarCollapsed, isFalse);
    expect(service.selectedMonth, isNull);
    expect(service.selectedYear, isNull);
  });

  test('persists the appearance mode between instances', () async {
    final service = await loadService();
    await service.setThemeMode(ThemeMode.dark);

    final reloaded = await PreferencesService.load();
    expect(reloaded.themeMode, ThemeMode.dark);

    await reloaded.setThemeMode(ThemeMode.light);
    expect((await PreferencesService.load()).themeMode, ThemeMode.light);
  });

  test('persists the collapsed sidebar state', () async {
    final service = await loadService();
    await service.setSidebarCollapsed(true);

    expect((await PreferencesService.load()).sidebarCollapsed, isTrue);
  });

  test('persists and clears the selected report period', () async {
    final service = await loadService();
    await service.setSelectedMonth('2026/05');
    await service.setSelectedYear('2026');

    final reloaded = await PreferencesService.load();
    expect(reloaded.selectedMonth, '2026/05');
    expect(reloaded.selectedYear, '2026');

    await reloaded.setSelectedMonth(null);
    await reloaded.setSelectedYear(null);

    final cleared = await PreferencesService.load();
    expect(cleared.selectedMonth, isNull);
    expect(cleared.selectedYear, isNull);
  });

  test('reads a previously stored appearance mode', () async {
    final service = await loadService({
      PreferencesService.themeModeKey: 'light',
    });

    expect(service.themeMode, ThemeMode.light);
  });
}
