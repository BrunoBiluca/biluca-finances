import 'dart:math';
import 'package:biluca_financas/components/single_value_card.dart';
import 'package:biluca_financas/components/values_relation_indicator.dart';
import 'package:flutter/material.dart';

class PositiveValuesRelationIndicator extends ValuesRelationIndicator {
  final Color positiveText = const Color(0xFF43C67C);
  final Color positiveBackgroud = const Color(0xFF122622);
  final Color positiveBorder = const Color(0xFF232428);

  final bool isUp;
  const PositiveValuesRelationIndicator({super.key, this.isUp = true});

  @override
  double get rotation => pi / 8;

  @override
  Color get bgColor => positiveBackgroud;

  @override
  Color get borderColor => positiveBorder;

  @override
  IconData get icon => isUp ? Icons.keyboard_double_arrow_up : Icons.keyboard_double_arrow_down;

  @override
  Color get txtColor => positiveText;
}
