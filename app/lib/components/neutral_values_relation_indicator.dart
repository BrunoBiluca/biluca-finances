import 'package:biluca_financas/components/single_value_card.dart';
import 'package:biluca_financas/components/values_relation_indicator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NeutralValuesRelationIndicator extends ValuesRelationIndicator {
  final Color neutralText = const Color(0xFF988F81);
  final Color neutralBackgroud = const Color(0xFF232428);
  final Color neutralBorder = const Color.fromARGB(255, 72, 74, 82);

  const NeutralValuesRelationIndicator({super.key});

  @override
  Color get bgColor => neutralBackgroud;

  @override
  Color get borderColor => neutralBorder;

  @override
  IconData get icon => FontAwesomeIcons.equals;

  @override
  Color get txtColor => neutralText;
}
