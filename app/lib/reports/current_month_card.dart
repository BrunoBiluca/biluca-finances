import 'package:biluca_financas/accountability/current_month_service.dart';
import 'package:biluca_financas/common/formatter.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CurrentMonthCard extends StatelessWidget {
  final AccountabilityCurrentMonthService service;
  const CurrentMonthCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        children: [
          const Text("Balanço: "),
          const SizedBox(width: 5),
          FutureBuilder(
            future: service.getBalance(),
            builder: (c, s) {
              if (s.connectionState != ConnectionState.done) {
                return textShimmer();
              }
              return Text(Formatter.number(s.data!));
            },
          ),
          const SizedBox(width: 20),
          const Text("Gastos: "),
          const SizedBox(width: 5),
          FutureBuilder(
            future: service.getExpenses(),
            builder: (c, s) {
              if (s.connectionState != ConnectionState.done) {
                return textShimmer();
              }
              return Text(Formatter.number(s.data!));
            },
          ),
          const SizedBox(width: 20),
          const Text("Receitas: "),
          const SizedBox(width: 5),
          FutureBuilder(
            future: service.getIncomes(),
            builder: (c, s) {
              if (s.connectionState != ConnectionState.done) {
                return textShimmer();
              }
              return Text(Formatter.number(s.data!));
            },
          ),
        ],
      ),
    ]);
  }

  SizedBox textShimmer() {
    return SizedBox(
      width: 200.0,
      height: 100.0,
      child: Shimmer.fromColors(
        baseColor: Colors.red,
        highlightColor: Colors.yellow,
        child: const Text(
          'Shimmer',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 40.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
