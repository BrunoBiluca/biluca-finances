import 'dart:collection';

import 'package:biluca_financas/app/themes/app_theme.dart';
import 'package:flutter/material.dart';

class ThemeManager {
  HashMap<String, AppTheme> themes = HashMap();

  ThemeManager();

  late ThemeData? _dark;
  late ThemeData? _light;

  late String _darkId;
  late String _lightId;

  ThemeData get dark => _dark!;

  ThemeData get light => _light!;

  void add(AppTheme theme) => themes[theme.name] = theme;

  void setDark(String name) {
    _darkId = name;
    _dark = themes[name]?.build();
  }

  void setLight(String name) {
    _lightId = name;
    _light = themes[name]?.build();
  }

  AppTheme getCurrentTheme(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? themes[_darkId]! : themes[_lightId]!;
  }
}
