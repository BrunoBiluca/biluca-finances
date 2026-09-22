import 'package:biluca_financas/common/extensions/currency.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

FlGridData defaultGrid() => FlGridData(
      show: true,
      drawVerticalLine: false,
      getDrawingHorizontalLine: (value) => FlLine(
        dashArray: [5, 10],
        color: Colors.white.withValues(alpha: 0.1),
        strokeWidth: 1,
      ),
    );

FlBorderData defaultBorder() => FlBorderData(
      show: true,
      border: Border(
        bottom: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1),
        left: const BorderSide(color: Colors.transparent),
        right: const BorderSide(color: Colors.transparent),
        top: const BorderSide(color: Colors.transparent),
      ),
    );

LineTouchData defaultLineTouchForCurrency() => LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipItems: (touchedSpots) => touchedSpots
            .map(
              (spot) => LineTooltipItem(
                spot.y == 0 ? 'EMPTY' : formatReal(spot.y),
                TextStyle(
                  color: spot.bar.color?.withAlpha(255),
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
            .toList(),
      ),
    );

BarTouchData defaultBarTouchData() => BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (spot) => Colors.blueGrey,
        getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
          formatReal(rod.toY),
          TextStyle(
            color: rod.color?.withAlpha(255),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

FlTitlesData defaultTitlesForCurrency(
  List<String> monthdata, {
  double rotation = 0.0,
  double? maxY,
}) =>
    FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          interval: 1,
          getTitlesWidget: (value, meta) {
            if (value < 0 || value == monthdata.length) return const SizedBox.shrink();
            return SideTitleWidget(
              meta: meta,
              space: 10,
              child: Transform.rotate(
                angle: rotation,
                child: Text(
                  monthdata[value.toInt()],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          getTitlesWidget: (double value, TitleMeta meta) {
            var divisor = maxY != null && maxY > 10 * 1000 ? 1000 : 1;
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
    );
