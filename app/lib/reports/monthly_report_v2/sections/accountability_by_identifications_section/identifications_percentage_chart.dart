import 'package:biluca_financas/reports/monthly_report_v2/services/identification_report_info.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class IdentificationsPercentageChart extends StatelessWidget {
  final List<IdentificationReportInfo> data;
  const IdentificationsPercentageChart({super.key, required this.data});

  final blue1 = Colors.lightBlueAccent;
  final blue2 = Colors.lightBlue;

  final size = 35.0;
  final maxX = 10.0;
  final maxY = 10.0;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        height: 400,
        width: 400,
        child: ScatterChart(
          ScatterChartData(
            scatterSpots: getScatterStops(),
            minX: 0,
            maxX: maxX,
            minY: 0,
            maxY: maxY,
            borderData: FlBorderData(
              show: false,
            ),
            gridData: const FlGridData(
              show: false,
            ),
            titlesData: const FlTitlesData(
              show: false,
            ),
            scatterTouchData: ScatterTouchData(
              enabled: false,
            ),
          ),
          duration: const Duration(milliseconds: 600),
          curve: Curves.fastOutSlowIn,
        ),
      ),
    );
  }

  List<ScatterSpot> getScatterStops() {
    var sortedData = data.sorted((a, b) => b.currentPercentage.compareTo(a.currentPercentage));
    var totalSpots = maxX * maxY;
    var spotsPerCategory = sortedData.map((d) => (d.currentPercentage * totalSpots).round()).toList();

    var result = List<ScatterSpot>.empty(growable: true);
    int categoryIndex = 0;
    int spotsInCurrentCategory = 0;
    for (var j = maxY - 1; j >= 0; j--) {
      for (var i = 0; i < maxX; i++) {
        if (categoryIndex >= sortedData.length) break;

        result.add(
          ScatterSpot(
            i.toDouble(),
            j.toDouble(),
            dotPainter: FlDotSquarePainter(
              color: sortedData[categoryIndex].identification.color,
              strokeColor: sortedData[categoryIndex].identification.color,
              size: size,
            ),
          ),
        );

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
