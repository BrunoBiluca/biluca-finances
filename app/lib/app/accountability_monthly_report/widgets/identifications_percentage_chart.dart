import 'package:biluca_financas/common/extensions/color_extensions.dart';
import 'package:biluca_financas/common/ui/reports/charts/rounded_rect_dot_painter.dart';
import 'package:biluca_financas/core/accountability_monthly_report/models/identification_report_info.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class IdentificationsPercentageChart extends StatelessWidget {
  final List<IdentificationReportInfo> data;
  const IdentificationsPercentageChart({super.key, required this.data});

  final size = 26.0;

  final maxX = 10;

  final maxY = 10;

  @override
  Widget build(BuildContext context) {
    var spots = getScatterStops();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.addBrightness(10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          spacing: 20,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Composição relativa",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 300,
              width: 300,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
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
            SizedBox(
              width: 300,
              child: buildLegend(context),
            )
          ],
        ),
      ),
    );
  }

  Row buildLegend(BuildContext context) {
    return Row(
      spacing: 14,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 6,
            children: data.indexed
                .where((e) => e.$1 % 2 == 0)
                .map(
                  (e) => buildLegendRow(e, context),
                )
                .toList(),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 6,
            children: data.indexed
                .where((e) => e.$1 % 2 == 1)
                .map(
                  (e) => buildLegendRow(e, context),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Row buildLegendRow((int, IdentificationReportInfo) e, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(4),
            color: e.$2.identification.color,
          ),
          child: const SizedBox(width: 12, height: 12),
        ),
        Flexible(
          child: Text(
            "${e.$2.identification.description} (${(e.$2.participationInTotal * 100).toStringAsFixed(2)}%)",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
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
