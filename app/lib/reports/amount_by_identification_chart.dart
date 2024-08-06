import 'package:biluca_financas/accountability/models/identification.dart';
import 'package:biluca_financas/common/data/grouped_by.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AmountByIdentificationChart extends StatelessWidget {
  final List<GroupedBy<AccountabilityIdentification>> accountabilityByIdentification;
  final double barWidth = 20;
  const AmountByIdentificationChart({super.key, required this.accountabilityByIdentification});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceEvenly,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: bottomTitles,
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(
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
          checkToShowHorizontalLine: (value) => value % 5 == 0,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(.5),
            strokeWidth: 1,
          ),
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(
          show: false,
        ),
        barGroups: barGroups(),
      ),
    );
  }

  List<BarChartGroupData> barGroups() {
    return accountabilityByIdentification
        .asMap()
        .map(
          (i, e) => MapEntry(
            i,
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: e.total.abs(),
                  color: e.field.color,
                  borderSide: e.total < 0
                      ? const BorderSide(color: Colors.redAccent, width: 3)
                      : const BorderSide(color: Colors.green, width: 3),
                  width: barWidth,
                ),
              ],
            ),
          ),
        )
        .values
        .toList();
  }

  Widget bottomTitles(double groupKey, TitleMeta meta) {
    const style = TextStyle(fontSize: 10);
    return SideTitleWidget(
      axisSide: meta.axisSide,
      angle: 0.5,
      space: 12,
      child: Text(
        accountabilityByIdentification[groupKey.toInt()].field.description,
        style: style,
      ),
    );
  }
}
