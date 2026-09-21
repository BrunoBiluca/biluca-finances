import 'package:biluca_financas/app/accountability_yearly_report/widgets/balance_chart.dart';
import 'package:biluca_financas/app/accountability_yearly_report/widgets/incomes_expenses_evolution_chart.dart';
import 'package:biluca_financas/common/ui/reports/summary_chart_card/summary_chart_card.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:biluca_financas/core/accountability_yearly_report/models/monthly_summary.dart';
import 'package:biluca_financas/common/extensions/number_extensions.dart';
import 'package:intl/intl.dart';

class YearlySummaryCharts extends StatelessWidget {
  const YearlySummaryCharts({
    super.key,
    required this.res,
  });

  final List<MonthlySummary> res;

  @override
  Widget build(BuildContext context) {
    var maxValue = 0.0;
    for (var e in res) {
      if (e.sumIncomes > maxValue) {
        maxValue = e.sumIncomes.abs();
      }
      if (e.sumExpenses > maxValue) {
        maxValue = e.sumExpenses.abs();
      }
    }

    var maxBalanceValue = res.map((e) => e.balance.abs()).toList().max;
    var monthEntries = res.sortedBy((e) => e.month);

    var validEntries = monthEntries.where((e) => e.sumIncomes != 0).toList();

    var avgBalance = monthEntries.map((e) => e.balance).toList().average.abs();
    var sdBalance = monthEntries.map((e) => e.balance).toList().standardDeviation.abs();

    var avgIncomes = validEntries.map((e) => e.sumIncomes).toList().average;
    var sdIncomes = validEntries.map((e) => e.sumIncomes).toList().standardDeviation;

    var avgExpenses = validEntries.map((e) => e.sumExpenses).toList().average.abs();
    var sdExpenses = validEntries.map((e) => e.sumExpenses).toList().standardDeviation.abs();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        IncomesExpensesEvolutionChart(
          monthEntries: monthEntries,
          maxValue: maxValue,
          avgIncomes: avgIncomes,
          sdIncomes: sdIncomes,
          avgExpenses: avgExpenses,
          sdExpenses: sdExpenses,
        ),
        BalanceChart(
          monthEntries: monthEntries,
          maxValue: maxBalanceValue,
          avgBalance: avgBalance,
          sdBalance: sdBalance,
        ),
      ],
    );
  }
}
