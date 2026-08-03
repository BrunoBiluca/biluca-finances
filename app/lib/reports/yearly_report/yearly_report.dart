import 'package:biluca_financas/reports/accountability_stats_service.dart';
import 'package:biluca_financas/reports/components/future_handler.dart';
import 'package:biluca_financas/reports/yearly_report/year_selector.dart';
import 'package:biluca_financas/reports/yearly_report/yearly_identifications_summary_charts.dart';
import 'package:biluca_financas/reports/yearly_report/yearly_report_service.dart';
import 'package:biluca_financas/reports/yearly_report/yearly_summary_cards.dart';
import 'package:biluca_financas/reports/yearly_report/yearly_summary_charts.dart';
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
                    futureHandler(
                      service!.summary(),
                      (res) => YearlySummaryCards(res: res),
                    ),
                    const SizedBox(height: 20),
                    futureHandler(
                      service!.getMonthlySummary(),
                      (res) => YearlySummaryCharts(res: res),
                    ),
                    const SizedBox(height: 20),
                    futureHandler(
                      service!.getMonthlyIdentificationsSummary(),
                      (res) => YearlyIdentificationsSummaryCharts(res: res),
                    ),
                    const SizedBox(height: 100),
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
