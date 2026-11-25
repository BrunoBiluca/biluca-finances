import 'package:biluca_financas/app/themes/app_colors.dart';
import 'package:biluca_financas/common/extensions/currency.dart';
import 'package:biluca_financas/common/ui/reports/charts/chart_legend.dart';
import 'package:biluca_financas/common/ui/reports/charts/charts.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';


import 'package:biluca_financas/common/ui/reports/summary_chart_card/summary_chart_card.dart';
import 'package:biluca_financas/core/accountability_yearly_report/models/monthly_summary.dart';

class IncomesExpensesEvolutionChart extends StatelessWidget {
  final List<MonthlySummary> monthEntries;
  final double maxValue;
  final double avgExpenses;
  final double sdExpenses;
  final double avgIncomes;
  final double sdIncomes;
  final double? chartHeight;

  const IncomesExpensesEvolutionChart({
    super.key,
    required this.monthEntries,
    required this.maxValue,
    required this.avgExpenses,
    required this.sdExpenses,
    required this.avgIncomes,
    required this.sdIncomes,
    this.chartHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SummaryChartCard(
      title: "Evolução das receitas e despesas",
      subtitle: "Série histórica temporal com linha de corte e desvio padrão médio",
      chart: buildIncomesAndExpensesChart(context),
      chartHeight: chartHeight,
      topRightInfo: buildLegend(context),
      subInfo: buildSubInfo(context),
    );
  }

  Widget buildIncomesAndExpensesChart(BuildContext context) {
    final colors = context.appColors;
    var incomesColor = colors.positiveYield;
    var expensesColor = colors.negativeYield;

    var monthData = monthEntries.map((e) => e.month).toList();

    return LineChart(
      LineChartData(
        minY: 0,
        minX: -1,
        maxX: monthEntries.length.toDouble(),
        lineBarsData: [
          LineChartBarData(
            color: incomesColor,
            gradientArea: LineChartGradientArea.wholeChart,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  incomesColor.withValues(alpha: 0.1),
                  incomesColor.withValues(alpha: 0),
                ],
                stops: const [0.5, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            spots: monthEntries
                .mapIndexed(
                  (int i, MonthlySummary e) => FlSpot(
                    i.toDouble(),
                    e.sumIncomes.abs(),
                  ),
                )
                .toList(),
          ),
          LineChartBarData(
            color: expensesColor.withAlpha(150),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  expensesColor.withValues(alpha: 0.1),
                  expensesColor.withValues(alpha: 0),
                ],
                stops: const [0.5, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            spots: monthEntries
                .mapIndexed(
                  (int i, MonthlySummary e) => FlSpot(
                    i.toDouble(),
                    e.sumExpenses.abs(),
                  ),
                )
                .toList(),
          ),
        ],
        titlesData: defaultTitlesForCurrency(monthData, maxY: maxValue),
        gridData: defaultGrid(),
        borderData: defaultBorder(),
        lineTouchData: defaultLineTouchForCurrency(),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: avgExpenses,
              color: expensesColor,
              strokeWidth: 1,
              dashArray: [10, 10],
            ),
            HorizontalLine(
              y: avgIncomes,
              color: incomesColor,
              strokeWidth: 1,
              dashArray: [10, 10],
            ),
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
    var incomesColor = colors.positiveYield;
    var expensesColor = colors.negativeYield;

    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 20,
      runSpacing: 8,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.start,
          spacing: 10,
          runSpacing: 4,
          children: [
            Text(
              "—",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: incomesColor,
                  ),
            ),
            Text(
              "Receitas: Média (Desvio):",
            ),
            Text(
              "${formatReal(avgIncomes)} (±${formatReal(sdIncomes)})",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: incomesColor,
                  ),
            )
          ],
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.start,
          spacing: 10,
          runSpacing: 4,
          children: [
            Text(
              "—",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: expensesColor,
                  ),
            ),
            Text(
              "Despesas: Média (Desvio):",
            ),
            Text(
              "${formatReal(avgExpenses)} (±${formatReal(sdExpenses)})",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: expensesColor,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
