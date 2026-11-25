import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color positiveYield;
  final Color positiveYieldBg;
  final Color positiveYieldAlt;
  final Color positiveYieldAltBg;
  final Color negativeYield;
  final Color negativeYieldBg;
  final Color neutralYield;
  final Color neutralYieldBg;

  final Color tableHeaderBackground;
  final Color tableRowAltBackground;
  final Color tableRowAltFieldBackground;
  final Color sidebarHighlightBackground;
  final Color modalFieldBorder;
  final Color modalFocusedFieldBorder;
  final Color chartNeutralBackground;
  final Color positiveComparisonBackground;
  final Color positiveComparisonText;
  final Color neutralComparisonBackground;
  final Color neutralComparisonText;
  final Color negativeComparisonBackground;
  final Color negativeComparisonText;

  const AppColors({
    required this.positiveYield,
    required this.positiveYieldAlt,
    required this.negativeYield,
    required this.neutralYield,
    required this.positiveYieldBg,
    required this.negativeYieldBg,
    required this.neutralYieldBg,
    required this.positiveYieldAltBg,
    required this.tableHeaderBackground,
    required this.tableRowAltBackground,
    required this.tableRowAltFieldBackground,
    required this.sidebarHighlightBackground,
    required this.modalFieldBorder,
    required this.modalFocusedFieldBorder,
    required this.chartNeutralBackground,
    this.positiveComparisonBackground = const Color(0xFF122622),
    this.positiveComparisonText = const Color(0xFF43C67C),
    this.neutralComparisonBackground = const Color(0xFF232428),
    this.neutralComparisonText = const Color(0xFF988F81),
    this.negativeComparisonBackground = const Color(0xFF24141B),
    this.negativeComparisonText = const Color(0xFFF54149),
  });

  @override
  AppColors copyWith({
    Color? positiveYield,
    Color? positiveYieldBg,
    Color? positiveYieldAlt,
    Color? positiveYieldAltBg,
    Color? negativeYield,
    Color? negativeYieldBg,
    Color? neutralYield,
    Color? neutralYieldBg,
    Color? tableHeaderBackground,
    Color? tableRowAltBackground,
    Color? tableRowAltFieldBackground,
    Color? sidebarHighlightBackground,
    Color? modalFieldBorder,
    Color? modalFocusedFieldBorder,
    Color? chartNeutralBackground,
    Color? positiveComparisonBackground,
    Color? positiveComparisonText,
    Color? neutralComparisonBackground,
    Color? neutralComparisonText,
    Color? negativeComparisonBackground,
    Color? negativeComparisonText,
  }) {
    return AppColors(
      positiveYield: positiveYield ?? this.positiveYield,
      positiveYieldBg: positiveYieldBg ?? this.positiveYieldBg,
      positiveYieldAlt: positiveYieldAlt ?? this.positiveYieldAlt,
      positiveYieldAltBg: positiveYieldAltBg ?? this.positiveYieldAltBg,
      negativeYield: negativeYield ?? this.negativeYield,
      negativeYieldBg: negativeYieldBg ?? this.negativeYieldBg,
      neutralYield: neutralYield ?? this.neutralYield,
      neutralYieldBg: neutralYieldBg ?? this.neutralYieldBg,
      tableHeaderBackground:
          tableHeaderBackground ?? this.tableHeaderBackground,
      tableRowAltBackground:
          tableRowAltBackground ?? this.tableRowAltBackground,
      tableRowAltFieldBackground:
          tableRowAltFieldBackground ?? this.tableRowAltFieldBackground,
      sidebarHighlightBackground:
          sidebarHighlightBackground ?? this.sidebarHighlightBackground,
      modalFieldBorder: modalFieldBorder ?? this.modalFieldBorder,
      modalFocusedFieldBorder:
          modalFocusedFieldBorder ?? this.modalFocusedFieldBorder,
      chartNeutralBackground:
          chartNeutralBackground ?? this.chartNeutralBackground,
      positiveComparisonBackground:
          positiveComparisonBackground ?? this.positiveComparisonBackground,
      positiveComparisonText:
          positiveComparisonText ?? this.positiveComparisonText,
      neutralComparisonBackground:
          neutralComparisonBackground ?? this.neutralComparisonBackground,
      neutralComparisonText: neutralComparisonText ?? this.neutralComparisonText,
      negativeComparisonBackground:
          negativeComparisonBackground ?? this.negativeComparisonBackground,
      negativeComparisonText:
          negativeComparisonText ?? this.negativeComparisonText,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      positiveYield: Color.lerp(positiveYield, other.positiveYield, t)!,
      positiveYieldBg: Color.lerp(positiveYieldBg, other.positiveYieldBg, t)!,
      positiveYieldAlt: Color.lerp(positiveYieldAlt, other.positiveYieldAlt, t)!,
      positiveYieldAltBg:
          Color.lerp(positiveYieldAltBg, other.positiveYieldAltBg, t)!,
      negativeYield: Color.lerp(negativeYield, other.negativeYield, t)!,
      negativeYieldBg: Color.lerp(negativeYieldBg, other.negativeYieldBg, t)!,
      neutralYield: Color.lerp(neutralYield, other.neutralYield, t)!,
      neutralYieldBg: Color.lerp(neutralYieldBg, other.neutralYieldBg, t)!,
      tableHeaderBackground:
          Color.lerp(tableHeaderBackground, other.tableHeaderBackground, t)!,
      tableRowAltBackground:
          Color.lerp(tableRowAltBackground, other.tableRowAltBackground, t)!,
      tableRowAltFieldBackground: Color.lerp(
          tableRowAltFieldBackground, other.tableRowAltFieldBackground, t)!,
      sidebarHighlightBackground: Color.lerp(sidebarHighlightBackground,
          other.sidebarHighlightBackground, t)!,
      modalFieldBorder: Color.lerp(modalFieldBorder, other.modalFieldBorder, t)!,
      modalFocusedFieldBorder:
          Color.lerp(modalFocusedFieldBorder, other.modalFocusedFieldBorder, t)!,
      chartNeutralBackground:
          Color.lerp(chartNeutralBackground, other.chartNeutralBackground, t)!,
      positiveComparisonBackground: Color.lerp(
          positiveComparisonBackground, other.positiveComparisonBackground, t)!,
      positiveComparisonText:
          Color.lerp(positiveComparisonText, other.positiveComparisonText, t)!,
      neutralComparisonBackground: Color.lerp(
          neutralComparisonBackground, other.neutralComparisonBackground, t)!,
      neutralComparisonText:
          Color.lerp(neutralComparisonText, other.neutralComparisonText, t)!,
      negativeComparisonBackground: Color.lerp(
          negativeComparisonBackground, other.negativeComparisonBackground, t)!,
      negativeComparisonText:
          Color.lerp(negativeComparisonText, other.negativeComparisonText, t)!,
    );
  }

  static const AppColors fallback = AppColors(
    positiveYield: Color(0xFF4EDEA3),
    positiveYieldBg: Color(0xFF173E3A),
    positiveYieldAlt: Color(0xFF8CD2FC),
    positiveYieldAltBg: Color(0xFF213F53),
    negativeYield: Color(0xFFFFBCBF),
    negativeYieldBg: Color(0xFF3E1629),
    neutralYield: Color(0xFFBDC8D1),
    neutralYieldBg: Color(0xFF313640),
    tableHeaderBackground: Color(0xFF0A0E17),
    tableRowAltBackground: Color(0xFF0A0E17),
    tableRowAltFieldBackground: Color(0xFF1C1F29),
    sidebarHighlightBackground: Color(0xFF262A34),
    modalFieldBorder: Color(0xFF272D36),
    modalFocusedFieldBorder: Color(0xFF3A424C),
    chartNeutralBackground: Color(0xFF616161),
  );
}

extension AppColorsContext on BuildContext {
  AppColors get appColors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.fallback;
}
