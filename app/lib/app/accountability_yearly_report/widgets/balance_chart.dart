import 'package:biluca_financas/common/extensions/currency.dart';
import 'package:biluca_financas/common/ui/reports/charts/charts.dart';
import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';

import 'package:biluca_financas/common/ui/reports/summary_chart_card/summary_chart_card.dart';
import 'package:biluca_financas/app/themes/app_colors.dart';
import 'package:biluca_financas/core/accountability_yearly_report/models/monthly_summary.dart';

class BalanceChart extends StatelessWidget {
  final List<MonthlySummary> monthEntries;
  final double maxValue;
  final double avgBalance;
  final double sdBalance;

  

  const BalanceChart({
    super.key,
    required this.monthEntries,
    required this.maxValue,
    required this.avgBalance,
    required this.sdBalance,
  });

  @override
  Widget build(BuildContext context) {
    return SummaryChartCard(
      title: "Balanço mensal",
      subtitle: "Resultado líquido apurado mês a mês com linha de referência média",
      chart: buildChart(context),
      topRightInfo: buildLegend(context),
      subInfo: buildSubInfo(context),
    );
  }

  Widget buildChart(BuildContext context) {
    final colors = context.appColors;
    var incomesColor = colors.positiveYield;
    var expensesColor = colors.negativeYield;

    var monthData = monthEntries.map((e) => e.month).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceEvenly,
        titlesData: defaultTitlesForCurrency(monthData, maxY: maxValue),
        gridData: defaultGrid(),
        borderData: defaultBorder(),
        barTouchData: defaultBarTouchData(),
        barGroups: [
          for (var i = 0; i < monthEntries.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                  toY: monthEntries[i].balance.abs(),
                  color: monthEntries[i].balance < 0 ? expensesColor : incomesColor,
                  width: 16,
                ),
              ],
            ),
        ],
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: avgBalance,
              color: avgBalance < 0 ? expensesColor : incomesColor,
              strokeWidth: 2,
              dashArray: [10, 10],
            )
          ],
        ),
      ),
    );
  }

  Widget buildLegend(BuildContext context) {
    final colors = context.appColors;
    var incomesColor = colors.positiveYield;
    var expensesColor = colors.negativeYield;

    return Row(
      spacing: 20,
      children: [
        Row(
          spacing: 10,
          children: [
            CircleAvatar(backgroundColor: incomesColor, radius: 10),
            Text("Receitas"),
          ],
        ),
        Row(
          spacing: 10,
          children: [
            CircleAvatar(backgroundColor: expensesColor, radius: 10),
            Text("Receitas"),
          ],
        )
      ],
    );
  }

  Widget buildSubInfo(BuildContext context) {
    final colors = context.appColors;
    var balanceColor = avgBalance < 0 ? colors.negativeYield : colors.positiveYield;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 10,
      children: [
        Text(
          "—",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: balanceColor,
              ),
        ),
        Text(
          "Balanço: Média (Desvio):",
        ),
        Text(
          "${formatReal(avgBalance)} (±${formatReal(sdBalance)})",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: balanceColor,
              ),
        )
      ],
    );
  }
}
