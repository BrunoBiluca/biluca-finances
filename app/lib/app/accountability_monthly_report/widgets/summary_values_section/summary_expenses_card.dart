import 'package:biluca_financas/common/ui/reports/future_handler.dart';
import 'package:biluca_financas/common/ui/reports/values_comparison_full_text.dart';
import 'package:biluca_financas/app/accountability_monthly_report/monthly_report_service.provider.dart';
import 'package:biluca_financas/common/ui/reports/consolidated_value_card.dart';
import 'package:flutter/material.dart';

class SummaryExpensesCard extends StatelessWidget {
  const SummaryExpensesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return futureHandler(
      MonthlyReportServiceProvider.of(context).summaryExpenses(),
      (d) => ConsolidatedValueCard(
        title: "Despesas",
        currentValue: d["expenses"],
        relatedValue: d["related"],
        lessIsPositive: true,
        extraInfo: ValuesComparisonFullText.from(
          d["expenses"],
          d["avgRecentMonts"],
          true,
          suffix: "em relação aos últimos 12 meses",
        ),
        tooltipSuffix: "mês anterior.",
      ),
    );
  }
}
