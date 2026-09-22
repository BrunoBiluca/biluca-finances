import 'package:biluca_financas/app/themes/theme_manager.dart';
import 'package:biluca_financas/common/extensions/currency.dart';
import 'package:biluca_financas/common/ui/reports/charts.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get_it/get_it.dart';

import 'package:biluca_financas/common/ui/reports/summary_chart_card/summary_chart_card.dart';
import 'package:biluca_financas/core/accountability_yearly_report/models/monthly_summary.dart';

class IncomesExpensesEvolutionChart extends StatelessWidget {
  final List<MonthlySummary> monthEntries;
  final double maxValue;
  final double avgExpenses;
  final double sdExpenses;
  final double avgIncomes;
  final double sdIncomes;

  final themeManager = GetIt.I<ThemeManager>();

  IncomesExpensesEvolutionChart({
    super.key,
    required this.monthEntries,
    required this.maxValue,
    required this.avgExpenses,
    required this.sdExpenses,
    required this.avgIncomes,
    required this.sdIncomes,
  });

  @override
  Widget build(BuildContext context) {
    return SummaryChartCard(
      title: "Evolução das receitas e despesas",
      subtitle: "Série histórica temporal com linha de corte e desvio padrão médio",
      chart: buildIncomesAndExpensesChart(context),
      topRightInfo: buildLegend(context),
      subInfo: buildSubInfo(context),
    );
  }

  Widget buildIncomesAndExpensesChart(BuildContext context) {
    var currTheme = themeManager.getCurrentTheme(context);
    var incomesColor = currTheme.colors.positiveYield;
    var expensesColor = currTheme.colors.negativeYield;

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
    var incomesColor = currTheme.colors.positiveYield;
    var expensesColor = currTheme.colors.negativeYield;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 10,
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
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 10,
            children: [
              Text(
                "—",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: expensesColor,
                    ),
              ),
              Text(
                "Receitas: Média (Desvio):",
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
        )
      ],
    );
  }
}
