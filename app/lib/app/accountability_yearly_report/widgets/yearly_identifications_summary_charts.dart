import 'dart:math';

import 'package:biluca_financas/common/ui/reports/charts.dart';
import 'package:biluca_financas/common/ui/reports/summary_chart_card/summary_chart_card.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'package:biluca_financas/core/accountability/models/accountability_identification_type.dart';
import 'package:biluca_financas/core/accountability_yearly_report/models/monthly_identifications_summary.dart';

class YearlyIdentificationsSummaryCharts extends StatelessWidget {
  final List<MonthlyIdentificationsSummary> res;
  const YearlyIdentificationsSummaryCharts({super.key, required this.res});

  String formatReal(double value) => "R\$ ${NumberFormat('#,##0.00', 'de').format(value)}";

  @override
  Widget build(BuildContext context) {
    var incomesIds = res.where((i) => i.identification.type == AccountabilityIdentificationType.income).length;
    var expensesIds = res.where((i) => i.identification.type == AccountabilityIdentificationType.expense).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Receitas por identificação",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              "$incomesIds fontes de receita consolidadas",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
        buildIdentificationsSection(AccountabilityIdentificationType.income),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Despesas por identificação",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              "$expensesIds fontes de despesa consolidadas",
              style: Theme.of(context).textTheme.bodyLarge,
            )
          ],
        ),
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
          var monthEntries = i.monthTotal.entries.sortedBy((entry) => entry.key);
          var monthData = monthEntries.map((e) => e.key).toList();

          var validEntries = monthEntries.where((entry) => entry.value != 0);
          var maxValue = validEntries.map((entry) => entry.value.abs()).max;
          var avgValue = validEntries.map((entry) => entry.value.abs()).average;
          var sumValue = monthEntries.map((e) => e.value.abs()).sum;

          return SummaryChartCard(
            icon: i.identification.icon,
            color: i.identification.color,
            title: i.identification.description,
            smallerTitle: true,
            subInfo: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Média: "),
                Text(
                  formatReal(sumValue),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: i.identification.color,
                  ),
                ),
              ],
            ),
            chart: BarChart(
              BarChartData(
                barGroups: monthEntries
                    .mapIndexed(
                      (index, entry) => BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value.abs(),
                            color: i.identification.color.withAlpha(
                              (entry.value / maxValue * 255).clamp(100, 255).toInt(),
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
                titlesData: defaultTitlesForCurrency(monthData, rotation: pi / 6, maxY: maxValue),
                gridData: defaultGrid(),
                borderData: defaultBorder(),
                barTouchData: defaultBarTouchData(),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: avgValue,
                      color: i.identification.color,
                      strokeWidth: 2,
                      dashArray: [10, 5],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ).toList(),
    );
  }
}
