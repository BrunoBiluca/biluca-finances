import 'package:biluca_financas/accountability/models/identification.dart';
import 'package:biluca_financas/reports/yearly_report/yearly_report_service.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class YearlyIdentificationsSummaryCharts extends StatelessWidget {
  final List<MonthlyIdentificationsSummary> res;
  const YearlyIdentificationsSummaryCharts({super.key, required this.res});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Receitas por identificação", style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 20),
        buildIdentificationsSection(AccountabilityIdentificationType.income),
        const SizedBox(height: 20),
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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
      ),
      children: res
          .where(
            (i) => i.identification.type == type,
          )
          .sortedBy((i) => i.identification.description)
          .map(
        (i) {
          var maxValue = i.monthTotal.entries.map((entry) => entry.value.abs()).max;
          var avgValue = i.monthTotal.entries.map((entry) => entry.value.abs()).average;
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
                  Text(
                    i.identification.description,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: BarChart(
                  BarChartData(
                    maxY: maxValue + maxValue * 0.2,
                    barGroups: i.monthTotal.entries
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
                            if (value.toInt() < 0 || value.toInt() >= i.monthTotal.length) {
                              return const SizedBox.shrink();
                            }
                            return Text(i.monthTotal.keys.elementAt(value.toInt()));
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
                          rod.toY.toStringAsFixed(2),
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
                            labelResolver: (line) => "R\$ ${avgValue.toStringAsFixed(2)}",
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
