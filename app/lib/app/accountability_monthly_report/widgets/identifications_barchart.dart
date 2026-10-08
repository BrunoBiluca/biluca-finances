import 'package:biluca_financas/common/ui/reports/charts/charts.dart';
import 'package:biluca_financas/core/accountability_monthly_report/models/identification_report_info.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class IdentificationsBarChart extends StatelessWidget {
  final List<IdentificationReportInfo> data;
  const IdentificationsBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    var maxCurrentValue = data.map((i) => i.current.abs()).max;
    var maxRelatedValue = data.map((i) => i.related.abs()).max;
    var maxValue = [maxCurrentValue, maxRelatedValue].max;

    return BarChart(
      BarChartData(
        maxY: maxValue + maxValue * 0.2,
        barGroups: data
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
                if (value.toInt() < 0 || value.toInt() >= data.length) {
                  return const SizedBox.shrink();
                }
                return Text(
                  data.elementAt(value.toInt()).identification.description,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              getTitlesWidget: (double value, TitleMeta meta) {
                var divisor = maxValue > 10 * 1000 ? 1000 : 1;
                var suffix = divisor == 1000 ? "k" : "";
                var thousands = (value.abs() / divisor).truncate();
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    "$thousands$suffix",
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
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        barTouchData: defaultBarTouchData(),
        gridData: defaultGrid(),
        borderData: defaultBorder(),
      ),
    );
  }
}
