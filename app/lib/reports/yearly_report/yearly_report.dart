import 'package:biluca_financas/reports/accountability_stats_service.dart';
import 'package:biluca_financas/reports/components/single_value_card.dart';
import 'package:biluca_financas/reports/yearly_report/year_selector.dart';
import 'package:biluca_financas/reports/yearly_report/yearly_report_service.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class YearlyReport extends StatefulWidget {
  const YearlyReport({super.key});

  @override
  State<YearlyReport> createState() => _YearlyReportState();
}

class _YearlyReportState extends State<YearlyReport> {
  String? currentYear;
  YearlyReportService? service;
  AccountabilityStatsService statsService = GetIt.I<AccountabilityStatsService>();

  void updateSelectedYear(String year) => setState(() => currentYear = year);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: statsService.getAllYearsWithAccountability(fillBlanks: true),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const CircularProgressIndicator();
        }

        currentYear ??= snapshot.data!.first.year;

        if (currentYear == "Últimos 12 meses") {
          var now = DateTime.now();
          service = GetIt.I<YearlyReportService>(
            param1: DateTime(now.year - 1, now.month, now.day),
            param2: now,
          );
        } else {
          service = GetIt.I<YearlyReportService>(
            param1: DateTime(int.parse(currentYear!), 1, 1),
            param2: DateTime(int.parse(currentYear!) + 1, 1, 1),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            YearSelector(
              currentYear: currentYear!,
              years: snapshot.data!,
              onDateChanged: (year) {
                setState(() => currentYear = year);
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    FutureBuilder(
                      future: service!.summary(),
                      builder: (context, snapshot2) {
                        if (snapshot2.connectionState != ConnectionState.done) {
                          return const CircularProgressIndicator();
                        }

                        var res = snapshot2.data!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Resumo", style: Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              spacing: 20,
                              children: [
                                Expanded(
                                  child: SingleValueCart(
                                    title: "Balanço",
                                    value: res.balance,
                                  ),
                                ),
                                Expanded(
                                  child: SingleValueCart(
                                    title: "Média mensal de balanços",
                                    value: res.avgBalance,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              spacing: 20,
                              children: [
                                Expanded(
                                  child: SingleValueCart(
                                    title: "Total de receitas",
                                    value: res.totalIncomes,
                                  ),
                                ),
                                Expanded(
                                  child: SingleValueCart(
                                    title: "Média mensal de receitas",
                                    value: res.avgIncomes,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              spacing: 20,
                              children: [
                                Expanded(
                                  child: SingleValueCart(
                                    title: "Total de despesas",
                                    value: res.totalExpenses,
                                  ),
                                ),
                                Expanded(
                                  child: SingleValueCart(
                                    title: "Média mensal de despesas",
                                    value: res.avgExpenses,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    FutureBuilder(
                      future: service!.getMonthlySummary(),
                      builder: (context, snapshot2) {
                        if (snapshot2.connectionState != ConnectionState.done) {
                          return const CircularProgressIndicator();
                        }

                        var res = snapshot2.data!;

                        var maxValue = 0.0;
                        for (var e in res) {
                          if (e.sumIncomes > maxValue) {
                            maxValue = e.sumIncomes.abs();
                          }
                          if (e.sumExpenses > maxValue) {
                            maxValue = e.sumExpenses.abs();
                          }
                        }

                        List<FlSpot> incomes = res
                            .mapIndexed(
                              (int i, MonthlySummary e) => FlSpot(
                                i.toDouble(),
                                e.sumIncomes.abs(),
                              ),
                            )
                            .toList();

                        List<FlSpot> expenses = res
                            .mapIndexed(
                              (int i, MonthlySummary e) => FlSpot(
                                i.toDouble(),
                                e.sumExpenses.abs(),
                              ),
                            )
                            .toList();

                        var incomeAvg = res.map((e) => e.sumIncomes).toList().average;
                        var expenseAvg = res.map((e) => e.sumExpenses.abs()).toList().average;

                        return SizedBox(
                          height: 400,
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 0),
                            child: LineChart(
                              LineChartData(
                                minY: 0,
                                maxY: maxValue + maxValue * 0.2,
                                lineBarsData: [
                                  LineChartBarData(
                                    color: Colors.green.withAlpha(100),
                                    barWidth: 4,
                                    isStrokeCapRound: true,
                                    dotData: const FlDotData(show: true),
                                    spots: incomes,
                                  ),
                                  LineChartBarData(
                                    color: Colors.redAccent.withAlpha(100),
                                    barWidth: 4,
                                    isStrokeCapRound: true,
                                    dotData: const FlDotData(show: true),
                                    spots: expenses,
                                  ),
                                ],
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 32,
                                      interval: 1,
                                      getTitlesWidget: (value, meta) {
                                        return SideTitleWidget(
                                          meta: meta,
                                          space: 10,
                                          child: Text(
                                            res[value.toInt()].month,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
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
                                        var thousands = (value.abs() / 1000).truncate();
                                        return SideTitleWidget(
                                          meta: meta,
                                          child: Text(
                                            "${thousands}k",
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
                                ),
                                gridData: FlGridData(
                                  show: false,
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border(
                                    bottom: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 4),
                                    left: const BorderSide(color: Colors.transparent),
                                    right: const BorderSide(color: Colors.transparent),
                                    top: const BorderSide(color: Colors.transparent),
                                  ),
                                ),
                                lineTouchData: LineTouchData(
                                  touchTooltipData: LineTouchTooltipData(
                                    getTooltipColor: (spot) => Colors.blueGrey, // Customize background
                                    getTooltipItems: (touchedSpots) => touchedSpots
                                        .map(
                                          (spot) => LineTooltipItem(
                                            spot.y.toStringAsFixed(2),
                                            TextStyle(color: spot.bar.color?.withAlpha(255), fontWeight: FontWeight.bold),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                                extraLinesData: ExtraLinesData(
                                  horizontalLines: [
                                    HorizontalLine(
                                      y: expenseAvg,
                                      color: Colors.redAccent,
                                      strokeWidth: 2,
                                      dashArray: [5, 10],
                                      label: HorizontalLineLabel(
                                        show: true,
                                        alignment: Alignment.topRight,
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        labelResolver: (line) => 'R\$ ${line.y.toStringAsFixed(1)}',
                                      ),
                                    ),
                                    HorizontalLine(
                                      y: incomeAvg,
                                      color: Colors.green,
                                      strokeWidth: 2,
                                      dashArray: [5, 10],
                                      label: HorizontalLineLabel(
                                        show: true,
                                        alignment: Alignment.topRight,
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        labelResolver: (line) => 'R\$ ${line.y.toStringAsFixed(1)}',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
