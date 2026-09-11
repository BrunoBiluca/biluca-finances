import 'package:biluca_financas/app/accountability_monthly_report/widgets/summary_values_section/summary_balance_card.dart';
import 'package:biluca_financas/app/accountability_monthly_report/widgets/summary_values_section/summary_expenses_card.dart';
import 'package:biluca_financas/app/accountability_monthly_report/widgets/summary_values_section/summary_incomes_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class SummaryValuesSection extends StatelessWidget {
  const SummaryValuesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      Text(
        "Resumo",
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 20),
      StaggeredGrid.count(
        crossAxisCount: 3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        children: [
          StaggeredGridTile.extent(
            crossAxisCellCount: 1,
            mainAxisExtent: 150,
            child: SummaryBalanceCard(
              key: const Key("summary_balance"),
            ),
          ),
          StaggeredGridTile.extent(
            crossAxisCellCount: 1,
            mainAxisExtent: 150,
            child: SummaryIncomesCard(
              key: const Key("summary_incomes"),
            ),
          ),
          StaggeredGridTile.extent(
            crossAxisCellCount: 1,
            mainAxisExtent: 150,
            child: SummaryExpensesCard(
              key: const Key("summary_expenses"),
            ),
          )
        ],
      )
    ]);
  }
}
