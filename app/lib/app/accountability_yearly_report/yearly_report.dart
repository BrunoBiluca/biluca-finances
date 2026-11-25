// ignore: unused_import
import 'package:biluca_financas/common/extensions/datetime_extensions.dart';
import 'package:biluca_financas/core/accountability_stats/services/accountability_stats_service.dart';
import 'package:biluca_financas/common/ui/reports/future_handler.dart';
import 'package:biluca_financas/common/ui/reports/report_header.dart';
import 'package:biluca_financas/app/accountability_yearly_report/widgets/year_selector.dart';
import 'package:biluca_financas/app/accountability_yearly_report/widgets/yearly_identifications_summary_charts.dart';
import 'package:biluca_financas/core/accountability_yearly_report/services/accountability_yearly_report_service.dart';
import 'package:biluca_financas/core/preferences/preferences_service.dart';
import 'package:biluca_financas/core/preferences/report_period_selection.dart';
import 'package:biluca_financas/app/accountability_yearly_report/widgets/yearly_summary_cards.dart';
import 'package:biluca_financas/app/accountability_yearly_report/widgets/yearly_summary_charts.dart';
import 'package:biluca_financas/di_container.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class YearlyReport extends StatefulWidget {
  const YearlyReport({super.key});

  @override
  State<YearlyReport> createState() => _YearlyReportState();
}

class _YearlyReportState extends State<YearlyReport> {
  String? currentYear;
  final preferences = GetIt.I<PreferencesService>();

  void updateSelectedYear(String year) {
    preferences.setSelectedYear(year);
    setState(() => currentYear = year);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: GetIt.I<AccountabilityStatsService>().getAllYearsWithAccountability(fillBlanks: true),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const CircularProgressIndicator();
        }

        final years = snapshot.data!;
        if (years.isEmpty) {
          return const Center(child: Text('Nenhum registro encontrado'));
        }

        AccountabilityYearlyReportService? service;
        currentYear ??= ReportPeriodSelection.resolveYear(
          availableYears: years,
          savedYear: preferences.selectedYear,
        )?.year;

        if (currentYear == "Últimos 12 meses") {
          var now = DateTime.now();
          service = GetIt.I.getAccountabilityYearlyReportService(
            start: DateTime(now.year - 1, now.month, 1),
            end: now,
          );
        } else {
          service = GetIt.I.getAccountabilityYearlyReportService(
            start: DateTime(int.parse(currentYear!), 1, 1),
            end: DateTime(int.parse(currentYear!) + 1, 1, 1),
          );
        }

        final reportService = service;

        return Column(
          spacing: 60,
          children: [
            ReportHeader(
              icon: Icons.space_dashboard,
              iconColor: Colors.blueAccent,
              title: "Relatório Anual",
              periodSelector: YearSelector(
                currentYear: currentYear!,
                years: years,
                onDateChanged: updateSelectedYear,
              ),
            ),
            FutureHandler(
              dependency: currentYear,
              load: () => reportService.summary(),
              builder: (context, res) => YearlySummaryCards(res: res),
            ),
            FutureHandler(
              dependency: currentYear,
              load: () => reportService.getMonthlySummary(),
              builder: (context, res) => YearlySummaryCharts(res: res),
              loadingBuilder: (_) => const SizedBox.shrink(),
            ),
            FutureHandler(
              dependency: currentYear,
              load: () => reportService.getMonthlyIdentificationsSummary(),
              builder: (context, res) =>
                  YearlyIdentificationsSummaryCharts(res: res),
              loadingBuilder: (_) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 100)
          ],
        );
      },
    );
  }
}
