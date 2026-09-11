import 'package:biluca_financas/core/accountability_monthly_report/models/identification_report_info.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class IdentificationsBarChart extends StatelessWidget {
  final List<IdentificationReportInfo> data;
  const IdentificationsBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    var ids = data.reversed;
    var maxCurrentValue = data.map((i) => i.current.abs()).max;
    var maxRelatedValue = data.map((i) => i.related.abs()).max;
    var maxValue = [maxCurrentValue, maxRelatedValue].max;

    return BarChart(
      BarChartData(
        maxY: maxValue + maxValue * 0.2,
        barGroups: ids
            .mapIndexed(
              (index, entry) => BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: entry.current.abs(),
                    width: 30,
                    borderRadius: BorderRadius.zero,
                    color: entry.identification.color,
                  ),
                  BarChartRodData(
                    toY: entry.related.abs(),
                    width: 30,
                    borderRadius: BorderRadius.zero,
                    color: entry.identification.color.withAlpha(80),
                  ),
                ],
              ),
            )
            .toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < 0 || value.toInt() >= ids.length) {
                  return const SizedBox.shrink();
                }
                return Text(
                  ids.elementAt(value.toInt()).identification.description,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              interval: (maxValue / 5 / 100).round() * 100 + 100,
              reservedSize: 60,
              getTitlesWidget: (double value, TitleMeta meta) {
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    value.toStringAsFixed(0),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
              showTitles: true,
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (spot) => Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
              "${rodIndex == 0 ? 'Atual\n' : 'Anterior\n'}${rod.toY.toStringAsFixed(2)}",
              textAlign: TextAlign.left,
              TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        gridData: FlGridData(show: false),
      ),
    );
  }
}
