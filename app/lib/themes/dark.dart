import 'package:biluca_financas/themes/app_theme.dart';
import 'package:flutter/material.dart';

class DarkTheme extends AppTheme{
  @override
  String get name => "dark";

  @override
  ThemeData build() {
    return ThemeData(
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF14161D),
        secondary: Color(0xFF2C2C2C),
        tertiary: Color(0xFF191919),
        outline: Color(0xFF232428),
      ),
      typography: Typography.material2021(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE8E6E3),
          secondary: Color(0xFF737373),
        ),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          color: Color(0xFF988F81),
        ),
        bodySmall: TextStyle(
          color: Color(0xFF988F81),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          iconColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
            var color = Color(0xFFFFFFFF);
            if (states.contains(WidgetState.hovered)) {
              return color.withOpacity(0.8);
            }
            return color;
          }),
          animationDuration: Duration(milliseconds: 100),
          alignment: Alignment.center,
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
            var color = Color(0xFF0073B9);
            if (states.contains(WidgetState.hovered)) {
              return color.withOpacity(0.8);
            }
            return color;
          }),
          padding: WidgetStateProperty.resolveWith<EdgeInsetsGeometry?>((Set<WidgetState> states) {
            return EdgeInsets.symmetric(horizontal: 32, vertical: 24);
          }),
          iconSize: WidgetStateProperty.resolveWith<double?>((Set<WidgetState> states) {
            return 32;
          }),
          shape: WidgetStateProperty.resolveWith<OutlinedBorder?>((Set<WidgetState> states) {
            return RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5)));
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
            var color = Color(0xFFFFFFFF);
            if (states.contains(WidgetState.hovered)) {
              return color.withOpacity(0.8);
            }
            return color;
          }),
          textStyle: WidgetStateProperty.resolveWith<TextStyle?>((Set<WidgetState> states) {
            var s = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
            return s;
          }),
        ),
      ),
      scaffoldBackgroundColor: const Color(0xFF000000),
    );
  }
}