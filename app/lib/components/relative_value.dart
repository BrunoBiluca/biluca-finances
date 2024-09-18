import 'package:biluca_financas/common/formatter.dart';
import 'package:biluca_financas/common/math.dart';
import 'package:biluca_financas/components/single_value_card.dart';
import 'package:flutter/material.dart';

class RelativeValue extends StatelessWidget {
  final Color positiveText = const Color(0xFF43C67C);
  final Color negativeText = const Color(0xFFF54149);
  final Color neutralText = const Color(0xFF988F81);

  final ValuesRelation type;
  final double value;
  const RelativeValue({super.key, required this.type, required this.value});

  factory RelativeValue.withValues(double current, double related, {bool lessIsPositite = false, Key? key}) {
    var relativePercentage = Math.relativePercentage(current, related);
    var relativeStatus = ValuesRelation.neutral;

    if (relativePercentage == 0) {
      relativeStatus = ValuesRelation.neutral;
    } else if (!relativePercentage.isFinite) {
      relativeStatus = ValuesRelation.unknown;
    } else if (!((relativePercentage > 0) ^ !lessIsPositite)) {
      relativeStatus = ValuesRelation.positive;
    } else {
      relativeStatus = ValuesRelation.negative;
    }

    return RelativeValue(
      type: relativeStatus,
      value: related,
      key: key,
    );
  }

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
      style: Theme.of(context).textTheme.displayMedium?.copyWith(color: textColor),
    );
  }
}
