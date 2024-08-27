import 'package:biluca_financas/reports/current_month_service.dart';
import 'package:biluca_financas/common/formatter.dart';
import 'package:biluca_financas/common/math.dart';
import 'package:biluca_financas/components/text_shimmer.dart';
import 'package:flutter/material.dart';

import '../components/future_number.dart';

class CurrentMonthCard extends StatelessWidget {
  final AccountabilityCurrentMonthService service;
  final AccountabilityCurrentMonthService lastMonthService;
  const CurrentMonthCard({
    super.key,
    required this.service,
    required this.lastMonthService,
  });

  Future<(double, double)> _expenses() async {
    var currentExpenses = await service.getExpenses();
    var lastMonthExpenses = await lastMonthService.getExpenses();

    return (
      currentExpenses,
      Math.relativePercentage(currentExpenses, lastMonthExpenses),
    );
  }

  Future<(double, double)> _incomes() async {
    var current = await service.getIncomes();
    var lastMonth = await lastMonthService.getIncomes();

    return (
      current,
      Math.relativePercentage(current, lastMonth),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Title(
              color: Colors.black,
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Resumo do Mês ${service.currentMonth}",
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                Row(
                  children: [
                    const Text("Balanço: "),
                    const SizedBox(width: 5),
                    FutureNumber(source: service.getSum, key: const Key("total")),
                    const SizedBox(width: 5),
                    FutureNumber(
                        source: service.getBalance,
                        formatter: (n) => "${Formatter.number(n * 100)}%",
                        key: const Key("balance")),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text("Gastos: "),
                    const SizedBox(width: 5),
                    FutureBuilder(
                      future: _expenses(),
                      builder: (c, s) {
                        if (s.connectionState != ConnectionState.done) {
                          return const TextShimmer();
                        }

                        return Row(
                          children: [
                            Text(Formatter.number(s.data!.$1), key: const Key("expenses_total")),
                            const SizedBox(width: 5),
                            Text(Formatter.percent(s.data!.$2), key: const Key("expenses_relative")),
                          ],
                        );
                      },
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text("Receitas: "),
                    const SizedBox(width: 5),
                    FutureBuilder(
                      future: _incomes(),
                      builder: (c, s) {
                        if (s.connectionState != ConnectionState.done) {
                          return const TextShimmer();
                        }

                        return Row(
                          children: [
                            Text(Formatter.number(s.data!.$1), key: const Key("incomes_total")),
                            const SizedBox(width: 5),
                            Text(Formatter.percent(s.data!.$2), key: const Key("incomes_relative")),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
