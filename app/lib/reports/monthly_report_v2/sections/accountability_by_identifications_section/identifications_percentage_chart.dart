import 'package:biluca_financas/reports/monthly_report_v2/services/identification_report_info.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class IdentificationsPercentageChart extends StatelessWidget {
  final List<IdentificationReportInfo> data;
  const IdentificationsPercentageChart({super.key, required this.data});

  final blue1 = Colors.lightBlueAccent;
  final blue2 = Colors.lightBlue;

  final radius = 20.0;
  final maxX = 10.0;
  final maxY = 10.0;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        height: 300,
        width: 300,
        child: ScatterChart(
          ScatterChartData(
            scatterSpots: flutterLogoData(),
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

  List<ScatterSpot> flutterLogoData() {
    var result = List<ScatterSpot>.empty(growable: true);

    var sortedData = data.sorted((a, b) => b.currentPercentage.compareTo(a.currentPercentage));

    for (var i = 0; i < maxX; i++) {
      for (var j = 0; j < maxY; j++) {
        result.add(
          ScatterSpot(
            i.toDouble(),
            j.toDouble(),
            dotPainter: FlDotSquarePainter(
              color: blue1,
              size: radius,
            ),
          ),
        );
      }
    }

    return result;
  }
}
