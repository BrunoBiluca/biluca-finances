import 'package:biluca_financas/common/formatter.dart';
import 'package:biluca_financas/common/math.dart';
import 'package:biluca_financas/components/base_decorated_card.dart';
import 'package:biluca_financas/components/negative_values_relation_indicator.dart';
import 'package:biluca_financas/components/neutral_values_relation_indicator.dart';
import 'package:biluca_financas/components/positive_values_relation_indicator.dart';
import 'package:biluca_financas/components/relative_value.dart';
import 'package:flutter/material.dart';

enum ValuesRelation { positive, negative, neutral, unknown }

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

      if (relativePercentage == 0) {
        relativeStatus = ValuesRelation.neutral;
      } else if (!relativePercentage!.isFinite) {
        relativeStatus = ValuesRelation.unknown;
      } else if (!((relativePercentage! > 0) ^ !widget.lessIsPositite)) {
        relativeStatus = ValuesRelation.positive;
      } else {
        relativeStatus = ValuesRelation.negative;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseDecoratedCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: Text(
                          Formatter.value(widget.currentValue),
                          key: const Key("valor"),
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                      ),
                      const SizedBox(width: 10),
                      relativePercentage == null
                          ? Container()
                          : RelativeValue(type: relativeStatus!, value: relativePercentage!),
                    ],
                  ),
                ),
                Text(
                  widget.title,
                  key: const Key("título"),
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ],
            ),
          ),
          switch (relativeStatus) {
            ValuesRelation.negative => NegativeValuesRelationIndicator(isUp: relativePercentage! > 0),
            ValuesRelation.positive => PositiveValuesRelationIndicator(isUp: relativePercentage! > 0),
            ValuesRelation.neutral => const NeutralValuesRelationIndicator(),
            ValuesRelation.unknown => const NeutralValuesRelationIndicator(),
            null => Container(),
          }
        ],
      ),
    );
  }
}
