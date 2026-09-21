import 'package:biluca_financas/common/extensions/currency.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:biluca_financas/common/ui/reports/summary_chart_card/summary_chart_card.dart';
import 'package:biluca_financas/app/themes/theme_manager.dart';
import 'package:biluca_financas/core/accountability_yearly_report/models/monthly_summary.dart';

class BalanceChart extends StatelessWidget {
  final List<MonthlySummary> monthEntries;
  final double maxValue;
  final double avgBalance;
  final double sdBalance;

  final themeManager = GetIt.I<ThemeManager>();

  BalanceChart({
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
      legend: buildLegend(context),
      subInfo: buildSubInfo(context),
    );
  }

  Widget buildChart(BuildContext context) {
    var currTheme = themeManager.getCurrentTheme(context);
    var incomesColor = currTheme.colors.positiveYield;
    var expensesColor = currTheme.colors.negativeYield;

    return BarChart(
      BarChartData(
        maxY: maxValue + maxValue * 0.2,
        alignment: BarChartAlignment.spaceEvenly,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 1,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                space: 10,
                child: Text(
                  monthEntries[value.toInt()].month,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              interval: 5 * 1000,
              getTitlesWidget: (double value, TitleMeta meta) {
                var thousands = (value.abs() / 1000).truncate();
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    "${thousands}k",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
              showTitles: true,
              reservedSize: 40,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            dashArray: [5, 10],
            color: Colors.white.withValues(alpha: 0.1),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (spot) => Colors.blueGrey, // Customize background
            getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
              formatReal(rod.toY),
              TextStyle(
                color: rod.color?.withAlpha(255),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
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
    var currTheme = themeManager.getCurrentTheme(context);
    var incomesColor = currTheme.colors.positiveYield;
    var expensesColor = currTheme.colors.negativeYield;

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
    var currTheme = themeManager.getCurrentTheme(context);
    var balanceColor = avgBalance < 0 ? currTheme.colors.negativeYield : currTheme.colors.positiveYield;

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
