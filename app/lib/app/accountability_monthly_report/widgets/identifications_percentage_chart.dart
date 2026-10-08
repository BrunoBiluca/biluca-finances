import 'package:biluca_financas/common/ui/reports/charts/rounded_rect_dot_painter.dart';
import 'package:biluca_financas/core/accountability_monthly_report/models/identification_report_info.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class IdentificationsPercentageChart extends StatelessWidget {
  final List<IdentificationReportInfo> data;
  const IdentificationsPercentageChart({super.key, required this.data});

  final size = 24.0;

  final maxX = 10;

  final maxY = 10;

  @override
  Widget build(BuildContext context) {
    var spots = getScatterStops();

    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        height: 300,
        width: 300,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor.withAlpha(150),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: ScatterChart(
              ScatterChartData(
                scatterSpots: spots.entries.map((e) => e.value['spot'] as ScatterSpot).toList(),
                minX: 0,
                maxX: maxX.toDouble(),
                minY: 0,
                maxY: maxY.toDouble(),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                scatterTouchData: ScatterTouchData(
                  enabled: true,
                  touchTooltipData: ScatterTouchTooltipData(
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    getTooltipItems: (spot) {
                      var info = spots["${spot.x.toInt()}_${spot.y.toInt()}"]['id'] as IdentificationReportInfo;
                      var identification = info.identification.description;
                      var percentage = "${(info.participationInTotal * 100).toStringAsFixed(2)}%";
                      return ScatterTooltipItem("$identification\n$percentage");
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> getScatterStops() {
    var sortedData = data.sorted((a, b) => b.participationInTotal.compareTo(a.participationInTotal));
    var totalSpots = maxX * maxY;
    var spotsPerCategory = sortedData.map((d) => (d.participationInTotal * totalSpots).round()).toList();

    var result = <String, dynamic>{};
    int categoryIndex = 0;
    int spotsInCurrentCategory = 0;
    for (var j = maxY - 1; j >= 0; j--) {
      for (var i = 0; i < maxX; i++) {
        if (categoryIndex >= sortedData.length) break;

        var id = sortedData[categoryIndex].identification;

        result["${i}_$j"] = {
          'id': sortedData[categoryIndex],
          'spot': ScatterSpot(
            i.toDouble() + 0.5,
            j.toDouble() + 0.5,
            dotPainter: RoundedRectDotPainter(
              color: id.color,
              width: size,
              height: size,
            ),
          ),
        };

        spotsInCurrentCategory++;

        if (spotsInCurrentCategory >= spotsPerCategory[categoryIndex]) {
          categoryIndex++;
          spotsInCurrentCategory = 0;
        }
      }
    }

    return result;
  }
}
