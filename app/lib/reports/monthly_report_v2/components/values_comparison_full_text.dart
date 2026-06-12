import 'package:biluca_financas/formatter.dart';
import 'package:biluca_financas/reports/models/values_relation.dart';
import 'package:biluca_financas/reports/monthly_report_v2/components/values_comparison.dart';
import 'package:flutter/material.dart';

class ValuesComparisonFullText extends StatelessWidget {
  final ValuesRelation values;
  final String? suffix;
  const ValuesComparisonFullText(
    this.values, {
    super.key,
    this.suffix,
  });

  factory ValuesComparisonFullText.from(
    double current,
    double related,
    bool lessIsPositite, {
    String? suffix,
  }) =>
      ValuesComparisonFullText(
        ValuesRelation(
          current,
          related,
          lessIsPositite: lessIsPositite,
        ),
        suffix: suffix,
      );

  @override
  Widget build(BuildContext context) {
    var theme = getTheme(values);
    var prefix = values.itIncreased()
        ? "Aumento de"
        : values.itDecreased()
            ? "Diminuiu em"
            : "Mantido";

    return RichText(
      text: TextSpan(
        text: "$prefix ",
        style: Theme.of(context).textTheme.bodySmall!,
        children: [
          TextSpan(
            text: Formatter.relationWithoutSign(values.percentage),
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme["txtColor"],
                ),
          ),
          TextSpan(
            text: " $suffix (${Formatter.value(values.related)})",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
