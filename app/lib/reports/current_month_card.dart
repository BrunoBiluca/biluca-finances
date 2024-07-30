import 'package:biluca_financas/accountability/current_month_service.dart';
import 'package:biluca_financas/common/formatter.dart';
import 'package:flutter/material.dart';

import '../components/future_number.dart';

class CurrentMonthCard extends StatelessWidget {
  final AccountabilityCurrentMonthService service;
  const CurrentMonthCard({super.key, required this.service});

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
                    FutureNumber(source: service.getSum),
                    const SizedBox(width: 5),
                    FutureNumber(source: service.getBalance, formatter: (n) => "${Formatter.number(n * 100)}%"),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text("Gastos: "),
                    const SizedBox(width: 5),
                    FutureNumber(source: service.getExpenses),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text("Receitas: "),
                    const SizedBox(width: 5),
                    FutureNumber(source: service.getIncomes),
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
