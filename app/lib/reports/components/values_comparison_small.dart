import 'package:biluca_financas/common/formatters/formatter.dart';
import 'package:biluca_financas/reports/components/report_tooltip.dart';
import 'package:biluca_financas/reports/models/values_relation.dart';
import 'package:biluca_financas/reports/components/values_comparison.dart';
import 'package:flutter/material.dart';

class ValuesComparisonSmall extends StatelessWidget {
  final ValuesRelation values;
  final String? label;
  final String? tooltipSuffix;
  const ValuesComparisonSmall(this.values, {super.key, this.label, this.tooltipSuffix});

  factory ValuesComparisonSmall.from(
    double current,
    double related,
    bool lessIsPositite, {
    String? label,
  }) =>
      ValuesComparisonSmall(
        ValuesRelation(
          current,
          related,
          lessIsPositite: lessIsPositite,
        ),
        label: label,
      );

  @override
  Widget build(BuildContext context) {
    var theme = getTheme(values);
    return ReportTooltip(
      message: values.type == ValuesRelationType.unknown
          ? "Sem comparação"
          : (values.itIncreased() ? "Aumentou" : "Diminuiu") +
              (tooltipSuffix != null ? " em relação ao $tooltipSuffix" : ""),
      verticalOffset: 20,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outline,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme["bgColor"],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Transform.rotate(
                    angle: theme["rotation"],
                    child: Icon(
                      theme["icon"],
                      color: theme["txtColor"],
                      size: Theme.of(context).textTheme.bodySmall!.fontSize,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    values.type == ValuesRelationType.unknown ? "?" : Formatter.relation(values.percentage),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: theme["txtColor"],
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  label != null ? const SizedBox(width: 8) : Container(),
                  label != null
                      ? Text(
                          label!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: theme["txtColor"],
                                fontWeight: FontWeight.bold,
                              ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
