import 'dart:math';

import 'package:biluca_financas/common/lib/values_relation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

dynamic positiveTheme(ValuesRelation values) => {
      "rotation": pi / 8,
      "bgColor": const Color(0xFF122622),
      "txtColor": const Color(0xFF43C67C),
      "icon": values.percentage > 0 ? Icons.keyboard_double_arrow_up : Icons.keyboard_double_arrow_down,
    };

dynamic neutralTheme(ValuesRelation values) => {
      "rotation": 0.0,
      "bgColor": const Color(0xFF232428),
      "txtColor": const Color(0xFF988F81),
      "icon": FontAwesomeIcons.equals,
    };

dynamic negativeTheme(ValuesRelation values) => {
      "rotation": pi / 8,
      "bgColor": const Color(0xFF24141B),
      "txtColor": const Color(0xFFF54149),
      "icon": values.percentage > 0 ? Icons.keyboard_double_arrow_up : Icons.keyboard_double_arrow_down,
    };

dynamic getTheme(ValuesRelation values) {
  return switch (values.type) {
    ValuesRelationType.negative => negativeTheme(values),
    ValuesRelationType.positive => positiveTheme(values),
    ValuesRelationType.neutral => neutralTheme(values),
    ValuesRelationType.unknown => neutralTheme(values)..["icon"] = Icons.question_mark,
  };
}
