import 'package:biluca_financas/reports/yearly_report/yearly_report_service.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

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

    List<FlSpot> incomes = res
        .mapIndexed(
          (int i, MonthlySummary e) => FlSpot(
            i.toDouble(),
            e.sumIncomes.abs(),
          ),
        )
        .toList();

    List<FlSpot> expenses = res
        .mapIndexed(
          (int i, MonthlySummary e) => FlSpot(
            i.toDouble(),
            e.sumExpenses.abs(),
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Evolução das receitas e despesas", style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 20),
        SizedBox(
          height: 400,
          width: double.infinity,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: maxValue + maxValue * 0.2,
              minX: -1,
              maxX: res.length.toDouble(),
              lineBarsData: [
                LineChartBarData(
                  color: Colors.green.withAlpha(150),
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  spots: incomes,
                ),
                LineChartBarData(
                  color: Colors.redAccent.withAlpha(150),
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  spots: expenses,
                ),
              ],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      if (value < 0 || value == res.length) return const SizedBox.shrink();
                      return SideTitleWidget(
                        meta: meta,
                        space: 10,
                        child: Text(
                          res[value.toInt()].month,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
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
              ),
              gridData: FlGridData(
                show: false,
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 4),
                  left: const BorderSide(color: Colors.transparent),
                  right: const BorderSide(color: Colors.transparent),
                  top: const BorderSide(color: Colors.transparent),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (spot) => Colors.blueGrey, // Customize background
                  getTooltipItems: (touchedSpots) => touchedSpots
                      .map(
                        (spot) => LineTooltipItem(
                          spot.y.toStringAsFixed(2),
                          TextStyle(
                            color: spot.bar.color?.withAlpha(255),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: res.map((e) => e.sumExpenses).toList().average,
                    color: Colors.redAccent,
                    strokeWidth: 2,
                    dashArray: [5, 10],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topLeft,
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      labelResolver: (line) => 'R\$ ${line.y.toStringAsFixed(1)}',
                    ),
                  ),
                  HorizontalLine(
                    y: res.map((e) => e.sumIncomes).toList().average,
                    color: Colors.green,
                    strokeWidth: 2,
                    dashArray: [5, 10],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topLeft,
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      labelResolver: (line) => 'R\$ ${line.y.toStringAsFixed(1)}',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text("Balanço mensal", style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 20),
        SizedBox(
          height: 400,
          child: BarChart(
            BarChartData(
              maxY: res.map((e) => e.balance.abs()).toList().max + res.map((e) => e.balance.abs()).toList().max * 0.2,
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
                        res[value.toInt()].month,
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
                show: false,
              ),
              borderData: FlBorderData(
                show: false,
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (spot) => Colors.blueGrey, // Customize background
                  getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                    rod.toY.toStringAsFixed(2),
                    TextStyle(
                      color: rod.color?.withAlpha(255),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              barGroups: [
                for (var i = 0; i < res.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: res[i].balance.abs(),
                        color: res[i].balance < 0 ? Colors.redAccent.withAlpha(150) : Colors.green.withAlpha(150),
                        width: 16,
                      ),
                    ],
                  ),
              ],
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: res.map((e) => e.balance).toList().average.abs(),
                    color: res.map((e) => e.balance).toList().average < 0 ? Colors.redAccent : Colors.green,
                    strokeWidth: 2,
                    dashArray: [5, 10],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topLeft,
                      style: TextStyle(
                        color: res.map((e) => e.balance).toList().average < 0 ? Colors.redAccent : Colors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      labelResolver: (line) => 'R\$ ${line.y.toStringAsFixed(1)}',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
