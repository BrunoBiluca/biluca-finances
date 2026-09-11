import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification_type.dart';
import 'package:biluca_financas/reports/yearly_report/yearly_report_service.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:biluca_financas/common/extensions/number_extensions.dart';
import 'package:intl/intl.dart';

class YearlyIdentificationsSummaryCharts extends StatelessWidget {
  final List<MonthlyIdentificationsSummary> res;
  const YearlyIdentificationsSummaryCharts({super.key, required this.res});

  String formatReal(double value) => "R\$ ${NumberFormat('#,##0.00', 'de').format(value)}";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Receitas por identificação", style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 20),
        buildIdentificationsSection(AccountabilityIdentificationType.income),
        const SizedBox(height: 60),
        Text("Despesas por identificação", style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 20),
        buildIdentificationsSection(AccountabilityIdentificationType.expense),
      ],
    );
  }

  GridView buildIdentificationsSection(AccountabilityIdentificationType type) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 700,
        childAspectRatio: 1.5,
        mainAxisSpacing: 60,
        crossAxisSpacing: 60,
      ),
      children: res
          .where(
            (i) => i.identification.type == type,
          )
          .sortedBy((i) => i.identification.description)
          .map(
        (i) {
          var monthEntries = i.monthTotal.entries.sortedBy((entry) => entry.key);

          var validEntries = monthEntries.where((entry) => entry.value != 0);
          var maxValue = validEntries.map((entry) => entry.value.abs()).max;
          var avgValue = validEntries.map((entry) => entry.value.abs()).average;
          var sdValue = validEntries.map((entry) => entry.value.abs()).standardDeviation;
          var sumValue = monthEntries.map((e) => e.value.abs()).sum;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: i.identification.color,
                    radius: 8,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      i.identification.description,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Text(
                    "Total: R\$ ${formatReal(sumValue)}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: BarChart(
                  BarChartData(
                    maxY: maxValue + maxValue * 0.2,
                    barGroups: monthEntries
                        .mapIndexed(
                          (index, entry) => BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: entry.value.abs(),
                                color: i.identification.color.withAlpha(150),
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
                            if (value.toInt() < 0 || value.toInt() >= monthEntries.length) {
                              return const SizedBox.shrink();
                            }
                            return Transform.translate(
                              offset: const Offset(0, 10),
                              child: Transform.rotate(
                                angle: 0.5,
                                child: Text(
                                  monthEntries.elementAt(value.toInt()).key,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                                ),
                              ),
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
                                formatReal(value),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
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
                          formatReal(rod.toY),
                          TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    gridData: FlGridData(show: false),
                    extraLinesData: ExtraLinesData(
                      horizontalLines: [
                        HorizontalLine(
                          y: avgValue,
                          color: i.identification.color,
                          strokeWidth: 2,
                          dashArray: [10, 5],
                          label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.topLeft,
                            labelResolver: (line) =>
                                "Média (Desvio)\n${formatReal(avgValue)} (+-${formatReal(sdValue)})",
                            style: TextStyle(
                              color: i.identification.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ).toList(),
    );
  }
}
