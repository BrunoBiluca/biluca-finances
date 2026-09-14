import 'dart:collection';

import 'package:biluca_financas/app/themes/app_theme.dart';
import 'package:flutter/material.dart';

class ThemeManager {
  HashMap<String, AppTheme> themes = HashMap();

  ThemeManager();

  late ThemeData? _dark;
  late ThemeData? _light;

  ThemeData get dark => _dark!;

  ThemeData get light => _light!;

  void add(AppTheme theme) => themes[theme.name] = theme;

  void setDark(String name) => _dark = themes[name]?.build();

  void setLight(String name) => _light = themes[name]?.build();
}
