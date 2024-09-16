import 'package:biluca_financas/accountability/models/identification.dart';
import 'package:biluca_financas/common/data/grouped_by.dart';
import 'package:biluca_financas/common/formatter.dart';
import 'package:biluca_financas/common/math.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AmountByIdentificationChart extends StatelessWidget {
  final Map<int, List<GroupedBy<AccountabilityIdentification>>> groups;
  final double barWidth = 40;
  factory AmountByIdentificationChart({
    required List<GroupedBy<AccountabilityIdentification>> accountabilityByIdentification,
    Key? key,
  }) {
    var groups = accountabilityByIdentification
        .groupListsBy((identification) => identification.field.id)
        .values
        .sorted((g1, g2) => g2[0].total.abs().compareTo(g1[0].total.abs()))
        .asMap()
        .map((index, group) => MapEntry(index, group));

    return AmountByIdentificationChart._(groups, key);
  }

  const AmountByIdentificationChart._(this.groups, Key? key) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Theme.of(context).colorScheme.primary,
            getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                BarTooltipItem(tooltip(group, groupIndex, rod, rodIndex), Theme.of(context).textTheme.displaySmall!),
          ),
        ),
        alignment: BarChartAlignment.spaceEvenly,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (double groupKey, TitleMeta meta) => bottomTitles(groupKey, meta, context),
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
            strokeWidth: .5,
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

  String tooltip(BarChartGroupData group, int groupIndex, BarChartRodData rod, int rodIndex) {
    var idGroup = groups[groupIndex]!;
    var desc = idGroup[0].field.description;
    var current = idGroup[0].total;
    var last = idGroup[1].total;
    var rel = Formatter.relation(Math.relativePercentage(current, last));

    var str = "$desc\n${current.abs().toStringAsFixed(2)}\n$rel";
    return str;
  }

  List<BarChartGroupData> barGroups() {
    return groups.values.mapIndexed(
      (index, group) {
        var color = group[0].field.color;
        var current = group[0].total.abs();
        var last = group.length > 1 ? group[1].total.abs() : 0.0;

        List<BarChartRodStackItem> items = [];
        var maxToY = 0.0;
        if (current > last) {
          maxToY = current;
          items = [
            BarChartRodStackItem(last, current, Color.fromARGB(255, 214, 63, 63)),
            BarChartRodStackItem(0, last, color),
          ];
        } else {
          maxToY = last;
          items = [
            BarChartRodStackItem(0, current, color),
            BarChartRodStackItem(current, last, Color.fromARGB(255, 83, 211, 149)),
          ];
        }

        return BarChartGroupData(
          x: index,
          barsSpace: 5,
          barRods: [
            BarChartRodData(
              toY: maxToY,
              width: barWidth,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
              borderSide: BorderSide(color: color, width: 4),
              rodStackItems: items,
            )
          ],
        );
      },
    ).toList();
  }

  Widget bottomTitles(double groupKey, TitleMeta meta, BuildContext context) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        groups[groupKey.toInt()]![0].field.description,
        style: Theme.of(context).textTheme.displaySmall,
      ),
    );
  }
}
