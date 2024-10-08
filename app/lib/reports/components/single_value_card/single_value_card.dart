import 'package:biluca_financas/formatter.dart';
import 'package:biluca_financas/components/base_decorated_card.dart';
import 'package:biluca_financas/reports/models/values_relation.dart';
import 'package:biluca_financas/reports/components/single_value_card/values_relation_indicator.dart';
import 'package:biluca_financas/reports/components/single_value_card/values_relation_text.dart';
import 'package:flutter/material.dart';

class SingleValueCard extends StatefulWidget {
  final String title;
  final double currentValue;
  final double? relatedValue;
  final double? displayValue;
  final bool lessIsPositite;
  final Widget? side;
  const SingleValueCard({
    super.key,
    required this.title,
    required this.currentValue,
    this.relatedValue,
    this.displayValue,
    this.lessIsPositite = false,
    this.side,
  });

  @override
  State<SingleValueCard> createState() => _SingleValueCardState();
}

class _SingleValueCardState extends State<SingleValueCard> {
  ValuesRelation? values;

  @override
  void initState() {
    super.initState();
    if (widget.relatedValue != null) {
      values = ValuesRelation(widget.currentValue, widget.relatedValue!, lessIsPositite: widget.lessIsPositite);
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
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Text(
                        Formatter.value(widget.displayValue != null ? widget.displayValue! : widget.currentValue),
                        key: const Key("valor"),
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ),
                    const SizedBox(width: 20),
                    values == null ? Container() : ValuesRelationText(values: values!),
                  ],
                ),
                Text(
                  widget.title,
                  key: const Key("título"),
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ],
            ),
          ),
          widget.side != null
              ? widget.side!
              : values != null
                  ? ValuesRelationIndicator(values: values!)
                  : Container(),
        ],
      ),
    );
  }
}
