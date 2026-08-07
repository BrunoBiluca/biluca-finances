import 'package:biluca_financas/reports/components/single_value_card.dart';
import 'package:biluca_financas/reports/yearly_report/yearly_report_service.dart';
import 'package:flutter/material.dart';

class YearlySummaryCards extends StatelessWidget {
  const YearlySummaryCards({
    super.key,
    required this.res,
  });

  final YearlySummary res;

  @override
  Widget build(BuildContext context) {
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
              child: SingleValueCard(
                title: "Balanço",
                value: res.balance,
              ),
            ),
            Expanded(
              child: SingleValueCard(
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
              child: SingleValueCard(
                title: "Total de receitas",
                value: res.totalIncomes,
              ),
            ),
            Expanded(
              child: SingleValueCard(
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
              child: SingleValueCard(
                title: "Total de despesas",
                value: res.totalExpenses,
              ),
            ),
            Expanded(
              child: SingleValueCard(
                title: "Média mensal de despesas",
                value: res.avgExpenses,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
