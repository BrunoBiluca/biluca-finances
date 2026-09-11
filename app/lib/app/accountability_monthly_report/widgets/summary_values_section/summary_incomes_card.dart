import 'package:biluca_financas/common/ui/reports/future_handler.dart';
import 'package:biluca_financas/common/ui/reports/values_comparison_full_text.dart';
import 'package:biluca_financas/app/accountability_monthly_report/monthly_report_service.provider.dart';
import 'package:biluca_financas/common/ui/reports/consolidated_value_card.dart';
import 'package:flutter/material.dart';

class SummaryIncomesCard extends StatelessWidget {
  const SummaryIncomesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return futureHandler(
      MonthlyReportServiceProvider.of(context).summaryIncomes(),
      (d) => ConsolidatedValueCard(
        title: "Receitas",
        currentValue: d["incomes"],
        relatedValue: d["related"],
        extraInfo: ValuesComparisonFullText.from(
          d["incomes"],
          d["avgRecentMonts"],
          false,
          suffix: "em relação aos últimos 12 meses",
        ),
        tooltipSuffix: "mês anterior.",
      ),
    );
  }
}
