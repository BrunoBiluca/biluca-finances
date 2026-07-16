import 'package:biluca_financas/reports/accountability_stats_service.dart';
import 'package:biluca_financas/reports/components/single_value_card.dart';
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Resumo", style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      spacing: 20,
                      children: [
                        Expanded(child: SingleValueCart(title: "Total de despesas", value: 10000)),
                        Expanded(child: SingleValueCart(title: "Média mensal de despesas", value: 10000)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      spacing: 20,
                      children: [
                        Expanded(child: SingleValueCart(title: "Total de receitas", value: 10000)),
                        Expanded(child: SingleValueCart(title: "Média mensal de receitas", value: 10000)),
                      ],
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
