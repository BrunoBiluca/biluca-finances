
import 'package:biluca_financas/common/formatter.dart';
import 'package:biluca_financas/common/math.dart';
import 'package:biluca_financas/components/negative_values_relation_indicator.dart';
import 'package:biluca_financas/components/neutral_values_relation_indicator.dart';
import 'package:biluca_financas/components/positive_values_relation_indicator.dart';
import 'package:biluca_financas/components/relative_value.dart';
import 'package:flutter/material.dart';

enum ValuesRelation { positive, negative, neutral }

class SingleValueCard extends StatefulWidget {
  final String title;
  final double currentValue;
  final double? lastValue;
  final bool lessIsPositite;
  const SingleValueCard({
    super.key,
    required this.title,
    required this.currentValue,
    this.lastValue,
    this.lessIsPositite = false,
  });

  @override
  State<SingleValueCard> createState() => _SingleValueCardState();
}

class _SingleValueCardState extends State<SingleValueCard> {
  double? relativePercentage;
  ValuesRelation? relativeStatus;

  @override
  void initState() {
    super.initState();
    if (widget.lastValue != null) {
      relativePercentage = Math.relativePercentage(widget.currentValue, widget.lastValue!);
      relativeStatus = relativePercentage == 0
          ? ValuesRelation.neutral
          : !((relativePercentage! > 0) ^ !widget.lessIsPositite)
              ? ValuesRelation.positive
              : ValuesRelation.negative;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Theme.of(context).colorScheme.outline, width: 4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      Formatter.value(widget.currentValue),
                      key: const Key("valor"),
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    SizedBox(width: 10),
                    relativePercentage == null
                        ? Container()
                        : RelativeValue(type: relativeStatus!, value: relativePercentage!),
                  ],
                ),
                Text(
                  widget.title,
                  key: const Key("título"),
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ],
            ),
            SizedBox(width: 30),
            relativeBox()
          ],
        ),
      ),
    );
  }

  Widget relativeBox() {
    if (relativePercentage == null) {
      return Container();
    }

    return relativeStatus! == ValuesRelation.positive
        ? PositiveValuesRelationIndicator(isUp: relativePercentage! > 0)
        : relativeStatus! == ValuesRelation.negative
            ? NegativeValuesRelationIndicator(isUp: relativePercentage! > 0)
            : const NeutralValuesRelationIndicator();
  }
}
