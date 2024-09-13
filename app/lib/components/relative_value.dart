import 'package:biluca_financas/common/formatter.dart';
import 'package:biluca_financas/components/single_value_card.dart';
import 'package:flutter/material.dart';

class RelativeValue extends StatelessWidget {
  final Color positiveText = const Color(0xFF43C67C);
  final Color negativeText = const Color(0xFFF54149);
  final Color neutralText = const Color(0xFF988F81);

  final ValuesRelation type;
  final double value;
  const RelativeValue({super.key, required this.type, required this.value});

  @override
  Widget build(BuildContext context) {
    var textColor = type == ValuesRelation.positive
        ? positiveText
        : type == ValuesRelation.negative
            ? negativeText
            : neutralText;

    return Text(
      Formatter.relation(value),
      key: const Key("relação"),
      style: Theme.of(context).textTheme.displayLarge?.copyWith(color: textColor),
    );
  }
}
