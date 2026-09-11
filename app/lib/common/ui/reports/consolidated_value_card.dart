import 'package:biluca_financas/common/formatters/formatter.dart';
import 'package:biluca_financas/common/ui/reports/report_tooltip.dart';
import 'package:biluca_financas/common/lib/values_relation.dart';
import 'package:biluca_financas/common/ui/reports/values_relation_indicator.dart';
import 'package:biluca_financas/common/ui/reports/values_relation_text.dart';
import 'package:flutter/material.dart';

class ConsolidatedValueCard extends StatefulWidget {
  final String title;
  final double currentValue;
  final double? relatedValue;
  final double? displayValue;
  final bool lessIsPositive;
  final Widget? extraInfo;
  final Widget? side;
  final String? tooltipSuffix;

  const ConsolidatedValueCard({
    super.key,
    required this.title,
    required this.currentValue,
    this.relatedValue,
    this.displayValue,
    this.lessIsPositive = false,
    this.side,
    this.extraInfo,
    this.tooltipSuffix,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Formatter.value(widget.displayValue != null ? widget.displayValue! : widget.currentValue),
                        key: const Key("valor"),
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      if (widget.extraInfo != null) ...[
                        SizedBox(height: 10),
                        widget.extraInfo!,
                      ],
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
                    ? ReportTooltip(
                        message: (values!.itIncreased() ? "Aumentou" : "Diminuiu") +
                            (widget.tooltipSuffix != null ? " em relação ao ${widget.tooltipSuffix}" : ""),
                        verticalOffset: 60,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ValuesRelationIndicator(values: values!),
                            SizedBox(height: 10),
                            ValuesRelationText(values: values!)
                          ],
                        ),
                      )
                    : Container(),
          ],
        ),
      ),
    );
  }
}
