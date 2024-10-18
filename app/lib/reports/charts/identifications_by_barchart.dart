
import 'package:biluca_financas/formatter.dart';
import 'package:biluca_financas/common/math.dart';
import 'package:biluca_financas/reports/current_month_report_service.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class IdentificationsByBarChart extends StatelessWidget {
  final List<IdentificationRelation> groups;
  final double barWidth = 40;
  factory IdentificationsByBarChart({
    required List<IdentificationRelation> accountabilityByIdentification,
    Key? key,
  }) {
    var sorted = accountabilityByIdentification.sorted(
      (a, b) => a.identification.description.compareTo(b.identification.description),
    );
    return IdentificationsByBarChart._(sorted, key);
  }

  const IdentificationsByBarChart._(this.groups, Key? key) : super(key: key);

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
    var idGroup = groups[groupIndex];
    var desc = idGroup.identification.description;
    var current = idGroup.current.abs();
    var str = "$desc\nR\$ ${current.abs().toStringAsFixed(2)}";

    var last = idGroup.related.abs();
    if (last > 1) {
      var rel = Formatter.relation(Math.relativePercentage(current, last));
      str += "\n$rel";
    } else {
      str += "\nN/A";
    }

    return str;
  }

  List<BarChartGroupData> barGroups() {
    return groups.mapIndexed(
      (index, group) {
        var color = group.identification.color;
        var current = group.current.abs();
        var last = group.related.abs();

        List<BarChartRodStackItem> items = [];
        var maxToY = 0.0;
        if (current > last) {
          maxToY = current;
          items.add(BarChartRodStackItem(last, current, const Color.fromARGB(255, 214, 63, 63)));

          if (last > 0) {
            items.add(BarChartRodStackItem(0, last, color));
          }
        } else {
          maxToY = last;

          if (current > 0) {
            items.add(BarChartRodStackItem(0, current, color));
          }
          items.add(BarChartRodStackItem(current, last, const Color.fromARGB(255, 83, 211, 149)));
        }

        return BarChartGroupData(
          x: index,
          barsSpace: 5,
          barRods: [
            BarChartRodData(
              toY: maxToY,
              width: barWidth,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
              borderSide: BorderSide(color: color, width: 12),
              rodStackItems: items,
            )
          ],
        );
      },
    ).toList();
  }

  Widget bottomTitles(double groupKey, TitleMeta meta, BuildContext context) {
    var id = groups[groupKey.toInt()].identification;
    var style = Theme.of(context).textTheme.displaySmall!;
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Tooltip(
        message: id.description,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            id.icon,
            size: style.fontSize! + 8.0,
            color: style.color,
          ),
        ),
      ),
    );
  }
}
