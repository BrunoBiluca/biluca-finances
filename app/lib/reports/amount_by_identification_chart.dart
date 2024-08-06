import 'package:biluca_financas/accountability/models/identification.dart';
import 'package:biluca_financas/common/data/grouped_by.dart';
import 'package:biluca_financas/common/math.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AmountByIdentificationChart extends StatelessWidget {
  final List<GroupedBy<AccountabilityIdentification>> accountabilityByIdentification;
  final double barWidth = 40;
  const AmountByIdentificationChart({super.key, required this.accountabilityByIdentification});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
              tooltip(group, rod, rodIndex),
              const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
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

  String tooltip(BarChartGroupData group, BarChartRodData rod, int rodIndex) {
    var nextRodIndex = (rodIndex + 1) % group.barRods.length;
    var nextValue = group.barRods[nextRodIndex].toY;
    var multiplier = (Math.relativeMultiplier(rod.toY, nextValue));

    var multiplierStr = "\n${multiplier.toStringAsFixed(2)}x";
    if (multiplier == double.infinity) {
      multiplierStr = "";
    }

    var valueStr = rod.toY.toStringAsFixed(2);
    return valueStr + multiplierStr;
  }

  List<BarChartGroupData> barGroups() {
    return accountabilityByIdentification
        .groupListsBy((identification) => identification.field.id)
        .values
        .sorted(compareGroups)
        .asMap()
        .map(
          (index, group) => MapEntry(
            index,
            BarChartGroupData(
              x: index,
              barsSpace: 5,
              barRods: [
                BarChartRodData(
                  toY: group[0].total.abs(),
                  color: group[0].field.color,
                  borderSide: group[0].total < 0
                      ? const BorderSide(color: Colors.redAccent, width: 3)
                      : const BorderSide(color: Colors.green, width: 3),
                  width: barWidth,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                ),
                BarChartRodData(
                  toY: group.length == 2 ? group[1].total.abs() : 0,
                  color: Colors.grey.withOpacity(.7),
                  borderSide: group[0].total < 0
                      ? const BorderSide(color: Colors.redAccent, width: 3)
                      : const BorderSide(color: Colors.green, width: 3),
                  width: barWidth,
                  borderRadius: BorderRadius.zero,
                )
              ],
            ),
          ),
        )
        .values
        .toList();
  }

  int compareGroups(
    List<GroupedBy<AccountabilityIdentification>> group1,
    List<GroupedBy<AccountabilityIdentification>> group2,
  ) =>
      group2[0].total.abs().compareTo(group1[0].total.abs());

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
