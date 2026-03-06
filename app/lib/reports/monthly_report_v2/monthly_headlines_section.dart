import 'package:biluca_financas/reports/monthly_report_v2/summary_balance_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class MonthlyHeadlinesSection extends StatelessWidget {
  const MonthlyHeadlinesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StaggeredGrid.count(
      crossAxisCount: 3,
      crossAxisSpacing: 20,
      mainAxisSpacing: 40,
      children: [
        StaggeredGridTile.extent(
          crossAxisCellCount: 1,
          mainAxisExtent: 150,
          child: SummaryBalanceCard(),
        ),
        StaggeredGridTile.extent(
          crossAxisCellCount: 1,
          mainAxisExtent: 150,
          child: Placeholder(),
        ),
        StaggeredGridTile.extent(
          crossAxisCellCount: 1,
          mainAxisExtent: 150,
          child: Placeholder(),
        )
      ],
    );
  }
}
