import 'package:biluca_financas/formatter.dart';
import 'package:biluca_financas/reports/models/values_relation.dart';
import 'package:biluca_financas/reports/components/single_value_card/values_relation_indicator.dart';
import 'package:biluca_financas/reports/components/single_value_card/values_relation_text.dart';
import 'package:flutter/material.dart';

class ConsolidatedValueCard extends StatefulWidget {
  final String title;
  final double currentValue;
  final double? relatedValue;
  final double? displayValue;
  final bool lessIsPositive;
  final Widget? side;

  const ConsolidatedValueCard({
    super.key,
    required this.title,
    required this.currentValue,
    this.relatedValue,
    this.displayValue,
    this.lessIsPositive = false,
    this.side,
  });

  @override
  State<ConsolidatedValueCard> createState() => _SingleValueCardState();
}

class _SingleValueCardState extends State<ConsolidatedValueCard> {
  ValuesRelation? values;

  @override
  void initState() {
    super.initState();
    if (widget.relatedValue != null) {
      values = ValuesRelation(widget.currentValue, widget.relatedValue!, lessIsPositite: widget.lessIsPositive);
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
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      Formatter.value(widget.displayValue != null ? widget.displayValue! : widget.currentValue),
                      key: const Key("valor"),
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    SizedBox(height: 30),
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
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ValuesRelationIndicator(values: values!),
                            SizedBox(height: 10),
                            ValuesRelationText(values: values!)
                          ],
                        )
                      : Container(),
            ],
          )),
    );
  }
}
