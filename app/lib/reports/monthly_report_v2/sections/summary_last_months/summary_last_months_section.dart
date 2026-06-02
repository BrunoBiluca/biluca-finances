import 'package:biluca_financas/common/extensions/datetime_extensions.dart';
import 'package:biluca_financas/reports/accountability_month_service.dart';
import 'package:biluca_financas/reports/monthly_report_v2/sections/summary_last_months/month_info_card.dart';
import 'package:biluca_financas/reports/monthly_report_v2/services/monthly_report_service.provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class SummaryLastMonthsSection extends StatelessWidget {
  const SummaryLastMonthsSection({super.key});

  @override
  Widget build(BuildContext context) {
    var current = MonthlyReportServiceProvider.of(context).current;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Resumo dos últimos 3 meses",
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
              mainAxisExtent: 170,
              child: MonthInfoCard(
                service: current,
                relatedMonthService: GetIt.I<AccountabilityMonthService>(
                  param1: DateFormat("MM/yyyy").parse(current.currentMonth).subtractMonth(1),
                ),
              ),
            ),
            StaggeredGridTile.extent(
              crossAxisCellCount: 1,
              mainAxisExtent: 170,
              child: MonthInfoCard(
                service: current,
                relatedMonthService: GetIt.I<AccountabilityMonthService>(
                  param1: DateFormat("MM/yyyy").parse(current.currentMonth).subtractMonth(2),
                ),
              ),
            ),
            StaggeredGridTile.extent(
              crossAxisCellCount: 1,
              mainAxisExtent: 170,
              child: MonthInfoCard(
                service: current,
                relatedMonthService: GetIt.I<AccountabilityMonthService>(
                  param1: DateFormat("MM/yyyy").parse(current.currentMonth).subtractMonth(3),
                ),
              ),
            )
          ],
        ),
      ],
    );
    ;
  }
}
