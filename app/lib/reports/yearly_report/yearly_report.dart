import 'package:biluca_financas/reports/accountability_stats_service.dart';
import 'package:biluca_financas/reports/components/single_value_card.dart';
import 'package:biluca_financas/reports/yearly_report/year_selector.dart';
import 'package:biluca_financas/reports/yearly_report/yearly_report_service.dart';
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
                        }),
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
