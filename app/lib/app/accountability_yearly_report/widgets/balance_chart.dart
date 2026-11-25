import 'package:biluca_financas/common/extensions/currency.dart';
import 'package:biluca_financas/common/ui/reports/charts/chart_legend.dart';
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
  final double? chartHeight;

  const BalanceChart({
    super.key,
    required this.monthEntries,
    required this.maxValue,
    required this.avgBalance,
    required this.sdBalance,
    this.chartHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SummaryChartCard(
      title: "Balanço mensal",
      subtitle: "Resultado líquido apurado mês a mês com linha de referência média",
      chart: buildChart(context),
      chartHeight: chartHeight,
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

    return ChartLegend(
      items: [
        ChartLegendItem(label: "Receitas", color: colors.positiveYield),
        ChartLegendItem(label: "Despesas", color: colors.negativeYield),
      ],
    );
  }

  Widget buildSubInfo(BuildContext context) {
    final colors = context.appColors;
    var balanceColor = avgBalance < 0 ? colors.negativeYield : colors.positiveYield;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.start,
      spacing: 10,
      runSpacing: 4,
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
