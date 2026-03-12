import 'package:biluca_financas/reports/components/future_handler.dart';
import 'package:biluca_financas/reports/monthly_report_v2/services/monthly_report_service.provider.dart';
import 'package:biluca_financas/reports/monthly_report_v2/components/consolidated_value_card.dart';
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
            ));
  }
}
