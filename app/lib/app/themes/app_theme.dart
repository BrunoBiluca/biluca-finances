import 'package:biluca_financas/app/themes/app_colors.dart';
import 'package:flutter/material.dart';

abstract class AppTheme {
  String get name;
  ThemeData build();
  AppColors get colors;
}
