import 'dart:math';
import 'package:biluca_financas/components/single_value_card.dart';
import 'package:biluca_financas/components/values_relation_indicator.dart';
import 'package:flutter/material.dart';

class NegativeValuesRelationIndicator extends ValuesRelationIndicator {
  final Color negativeText = const Color(0xFFF54149);
  final Color negativeBackgroud = const Color(0xFF24141B);
  final Color negativeBorder = const Color(0xFF232428);

  final bool isUp;
  const NegativeValuesRelationIndicator({super.key, this.isUp = true});

  @override
  double get rotation => pi / 8;

  @override
  Color get bgColor => negativeBackgroud;

  @override
  Color get borderColor => negativeBorder;

  @override
  IconData get icon => isUp ? Icons.keyboard_double_arrow_up : Icons.keyboard_double_arrow_down;

  @override
  Color get txtColor => negativeText;
}
