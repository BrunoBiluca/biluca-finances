import 'package:biluca_financas/app/themes/app_theme.dart';
import 'package:biluca_financas/app/themes/biluca_legacy/biluca_legacy_theme.dart';
import 'package:biluca_financas/app/themes/obsidian_wealth/obsidian_wealth_dark_theme.dart';
import 'package:biluca_financas/app/themes/obsidian_wealth/obsidian_wealth_light_theme.dart';
import 'package:biluca_financas/app/themes/theme_manager.dart';

List<AppTheme> getAvailableThemes() {
  return [
    BilucaLegacyDark(),
    ObsidianWealthDarkTheme(),
    ObsidianWealthLightTheme(),
  ];
}

ThemeManager setupThemes() {
  var themeManager = ThemeManager();

  for (var theme in getAvailableThemes()) {
    themeManager.add(theme);
  }

  themeManager.setDark("Obsidian Wealth Dark");
  themeManager.setLight("Obsidian Wealth Dark");
  return themeManager;
}
