import 'dart:math';

import 'package:biluca_financas/app/themes/app_colors.dart';
import 'package:biluca_financas/common/lib/values_relation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ValuesComparisonTheme {
  final double rotation;
  final Color bgColor;
  final Color txtColor;
  final IconData icon;

  const ValuesComparisonTheme({
    required this.rotation,
    required this.bgColor,
    required this.txtColor,
    required this.icon,
  });
}

ValuesComparisonTheme positiveTheme(ValuesRelation values, AppColors colors) =>
    ValuesComparisonTheme(
      rotation: pi / 8,
      bgColor: colors.positiveComparisonBackground,
      txtColor: colors.positiveComparisonText,
      icon: values.percentage > 0
          ? Icons.keyboard_double_arrow_up
          : Icons.keyboard_double_arrow_down,
    );

ValuesComparisonTheme neutralTheme(ValuesRelation values, AppColors colors) =>
    ValuesComparisonTheme(
      rotation: 0.0,
      bgColor: colors.neutralComparisonBackground,
      txtColor: colors.neutralComparisonText,
      icon: FontAwesomeIcons.equals,
    );

ValuesComparisonTheme negativeTheme(ValuesRelation values, AppColors colors) =>
    ValuesComparisonTheme(
      rotation: pi / 8,
      bgColor: colors.negativeComparisonBackground,
      txtColor: colors.negativeComparisonText,
      icon: values.percentage > 0
          ? Icons.keyboard_double_arrow_up
          : Icons.keyboard_double_arrow_down,
    );

ValuesComparisonTheme getTheme(ValuesRelation values, AppColors colors) {
  return switch (values.type) {
    ValuesRelationType.negative => negativeTheme(values, colors),
    ValuesRelationType.positive => positiveTheme(values, colors),
    ValuesRelationType.neutral => neutralTheme(values, colors),
    ValuesRelationType.unknown => ValuesComparisonTheme(
        rotation: 0.0,
        bgColor: colors.neutralComparisonBackground,
        txtColor: colors.neutralComparisonText,
        icon: Icons.question_mark,
      ),
  };
}