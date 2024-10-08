import 'dart:math';

import 'package:biluca_financas/reports/components/icon_highlight.dart';
import 'package:biluca_financas/reports/models/values_relation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ValuesRelationIndicator extends StatelessWidget {
  final dynamic theme;
  const ValuesRelationIndicator._({super.key, required this.theme});

  factory ValuesRelationIndicator({Key? key, required ValuesRelation values}) {
    return ValuesRelationIndicator._(
      theme: switch (values.type) {
        ValuesRelationType.negative => negativeTheme(values),
        ValuesRelationType.positive => positiveTheme(values),
        ValuesRelationType.neutral => neutralTheme(values),
        ValuesRelationType.unknown => neutralTheme(values)..["icon"] = Icons.question_mark,
      },
      key: key,
    );
  }

  final Color positiveBorder = const Color(0xFF232428);

  @override
  Widget build(BuildContext context) {
    return IconHighlight(
      bgColor: theme["bgColor"],
      borderColor: positiveBorder,
      txtColor: theme["txtColor"],
      icon: theme["icon"],
      rotation: theme["rotation"],
    );
  }

  static dynamic positiveTheme(ValuesRelation values) => {
        "rotation": pi / 8,
        "bgColor": const Color(0xFF122622),
        "txtColor": const Color(0xFF43C67C),
        "icon": values.percentage > 0 ? Icons.keyboard_double_arrow_up : Icons.keyboard_double_arrow_down,
      };

  static dynamic neutralTheme(ValuesRelation values) => {
        "rotation": 0.0,
        "bgColor": const Color(0xFF232428),
        "txtColor": const Color(0xFF988F81),
        "icon": FontAwesomeIcons.equals,
      };

  static dynamic negativeTheme(ValuesRelation values) => {
        "rotation": pi / 8,
        "bgColor": const Color(0xFF24141B),
        "txtColor": const Color(0xFFF54149),
        "icon": values.percentage > 0 ? Icons.keyboard_double_arrow_up : Icons.keyboard_double_arrow_down,
      };
}
