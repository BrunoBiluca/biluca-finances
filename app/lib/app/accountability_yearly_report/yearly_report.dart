// ignore: unused_import
import 'package:biluca_financas/common/extensions/datetime_extensions.dart';
import 'package:biluca_financas/core/accountability_stats/models/accountability_year_stats.dart';
import 'package:biluca_financas/core/accountability_stats/services/accountability_stats_service.dart';
import 'package:biluca_financas/common/ui/reports/future_handler.dart';
import 'package:biluca_financas/app/accountability_yearly_report/widgets/year_selector.dart';
import 'package:biluca_financas/app/accountability_yearly_report/widgets/yearly_identifications_summary_charts.dart';
import 'package:biluca_financas/core/accountability_yearly_report/services/accountability_yearly_report_service.dart';
import 'package:biluca_financas/app/accountability_yearly_report/widgets/yearly_summary_cards.dart';
import 'package:biluca_financas/app/accountability_yearly_report/widgets/yearly_summary_charts.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class YearlyReport extends StatefulWidget {
  const YearlyReport({super.key});

  @override
  State<YearlyReport> createState() => _YearlyReportState();
}

class _YearlyReportState extends State<YearlyReport> {
  String? currentYear;
  AccountabilityYearlyReportService? service;
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
          var end = DateTime(now.year, now.month, 0);
          service = GetIt.I<AccountabilityYearlyReportService>(
            param1: DateTime(end.year - 1, end.month, 1),
            param2: end,
          );
        } else {
          service = GetIt.I<AccountabilityYearlyReportService>(
            param1: DateTime(int.parse(currentYear!), 1, 1),
            param2: DateTime(int.parse(currentYear!) + 1, 1, 1),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 60,
          children: [
            buildReportHeader(context, snapshot),
            futureHandler(
              service!.summary(),
              (res) => YearlySummaryCards(res: res),
            ),
            futureHandler(
              service!.getMonthlySummary(),
              (res) => YearlySummaryCharts(res: res),
            ),
            futureHandler(
              service!.getMonthlyIdentificationsSummary(),
              (res) => YearlyIdentificationsSummaryCharts(res: res),
            ),
            const SizedBox(height: 100)
          ],
        );
      },
    );
  }

  Widget buildReportHeader(BuildContext context, AsyncSnapshot<List<AccountabilityYearStats>> snapshot) {
    return LayoutBuilder(
      builder: (context, constraints) => Row(
        spacing: 20,
        children: [
          Expanded(
            flex: constraints.maxWidth < 850 ? 1 : 4,
            child: Row(
              spacing: 10,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8),
                    color: Color(0xFF262A34),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.space_dashboard,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                Text(
                  "Relatório Anual",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Flexible(
            child: YearSelector(
              currentYear: currentYear!,
              years: snapshot.data!,
              onDateChanged: (year) {
                setState(() => currentYear = year);
              },
            ),
          ),
        ],
      ),
    );
  }
}
