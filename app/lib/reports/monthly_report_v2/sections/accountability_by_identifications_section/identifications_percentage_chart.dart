import 'package:biluca_financas/reports/monthly_report_v2/services/identification_report_info.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class IdentificationsPercentageChart extends StatelessWidget {
  final List<IdentificationReportInfo> data;
  const IdentificationsPercentageChart({super.key, required this.data});

  final blue1 = Colors.lightBlueAccent;
  final blue2 = Colors.lightBlue;

  final size = 26.0;
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
        child: ScatterChart(
          ScatterChartData(
            scatterSpots: spots.entries.map((e) => e.value['spot'] as ScatterSpot).toList(),
            minX: 0,
            maxX: maxX.toDouble(),
            minY: 0,
            maxY: maxY.toDouble(),
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
              enabled: true,
              touchTooltipData: ScatterTouchTooltipData(
                tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                getTooltipItems: (spot) {
                  var info = spots["${spot.x.toInt()}_${spot.y.toInt()}"];
                  var identification = "${info['id'].identification.description}";
                  var percentage = "${(info['id'].currentPercentage * 100).toStringAsFixed(2)}%";
                  return ScatterTooltipItem("$identification\n$percentage");
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> getScatterStops() {
    var sortedData = data.sorted((a, b) => b.currentPercentage.compareTo(a.currentPercentage));
    var totalSpots = maxX * maxY;
    var spotsPerCategory = sortedData.map((d) => (d.currentPercentage * totalSpots).round()).toList();

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
            i.toDouble(),
            j.toDouble(),
            dotPainter: FlDotSquarePainter(
              color: id.color,
              strokeColor: id.color,
              size: size,
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
