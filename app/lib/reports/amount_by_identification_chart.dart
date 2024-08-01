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
        alignment: BarChartAlignment.center,
        groupsSpace: 30,
        barTouchData: BarTouchData(
          enabled: true,
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: bottomTitles,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: leftTitles,
              interval: 5,
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
        barGroups: accountabilityByIdentification
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
            .toList(),
      ),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10);
    return SideTitleWidget(
      axisSide: meta.axisSide,
      angle: 0.5,
      space: 12,
      child: Text(
        accountabilityByIdentification[value.toInt()].field.description,
        style: style,
      ),
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    if (value == meta.max) {
      return Container();
    }
    const style = TextStyle(
      fontSize: 12,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        meta.formattedValue,
        style: style,
      ),
    );
  }
}
