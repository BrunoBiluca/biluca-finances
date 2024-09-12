import 'dart:collection';

import 'package:biluca_financas/themes/app_theme.dart';
import 'package:flutter/material.dart';

class ThemeManager {
  HashMap<String, ThemeData> themes = HashMap();

  ThemeManager();

  late ThemeData? _dark;
  late ThemeData? _light;

  void add(AppTheme theme) => themes[theme.name] = theme.build();

  void setDark(String name) => _dark = themes[name];

  void setLight(String name) => _light = themes[name];

  ThemeData get dark => _dark!;

  ThemeData get light => _light!;
}
