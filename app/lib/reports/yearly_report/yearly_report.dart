import 'package:biluca_financas/reports/accountability_stats_service.dart';
import 'package:biluca_financas/reports/yearly_report/year_selector.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class YearlyReport extends StatefulWidget {
  const YearlyReport({super.key});

  @override
  State<YearlyReport> createState() => _YearlyReportState();
}

class _YearlyReportState extends State<YearlyReport> {
  String? currentYear;
  AccountabilityStatsService service = GetIt.I<AccountabilityStatsService>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: service.getAllYearsWithAccountability(fillBlanks: true),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const CircularProgressIndicator();
        }

        currentYear ??= snapshot.data!.first.year;

        return Column(
          children: [
            YearSelector(
              currentYear: currentYear!,
              years: snapshot.data!,
              onDateChanged: (year) {
                setState(() => currentYear = year);
              },
            ),
            const SizedBox(height: 20),
            Text(currentYear ?? "Nenhum ano selecionado"),
          ],
        );
      },
    );
  }
}
