import 'package:biluca_financas/app/accountability_monthly_report/widgets/month_summary_card.dart';
import 'package:biluca_financas/app/themes/theme_manager.dart';
import 'package:biluca_financas/common/extensions/datetime_extensions.dart';
import 'package:biluca_financas/common/extensions/string_extensions.dart';
import 'package:biluca_financas/common/ui/reports/future_handler.dart';
import 'package:biluca_financas/core/accountability_monthly_report/services/accountability_month_service.dart';
import 'package:biluca_financas/app/accountability_monthly_report/monthly_report_service.provider.dart';
import 'package:biluca_financas/core/accountability_monthly_report/services/current_month_report.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class SummaryLastMonthsSection extends StatelessWidget {
  const SummaryLastMonthsSection({super.key});
  @override
  Widget build(BuildContext context) {
    var monthService = MonthlyReportServiceProvider.of(context);
    var appTheme = GetIt.I<ThemeManager>();
    var currTheme = appTheme.getCurrentTheme(context);

    return LayoutBuilder(
      builder: (context, constraints) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                spacing: 10,
                children: [
                  Icon(Icons.history, color: Theme.of(context).colorScheme.secondary),
                  Text(
                    "Histórico recente (Últimos 3 meses)",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          FutureHandler(
            key: Key(monthService.current.currentMonth.toString()),
            future: Future.wait(
              [
                getMonthData(monthService, 1, currTheme.colors.positiveYieldAlt),
                getMonthData(monthService, 2, currTheme.colors.positiveYield),
                getMonthData(monthService, 3, currTheme.colors.neutralYield),
              ],
            ),
            child: (res) => StaggeredGrid.count(
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: constraints.maxWidth < 850 ? 1 : 3,
              children: res
                  .map<Widget>(
                    (e) => StaggeredGridTile.extent(
                      mainAxisExtent: 300,
                      crossAxisCellCount: 1,
                      child: MonthSummaryCard(
                        title: e["title"],
                        balance: e["balance"],
                        incomes: e["incomes"],
                        expenses: e["expenses"],
                        color: e["color"],
                        label: "M-${e["subtractMonth"]}",
                      ),
                    ),
                  )
                  .toList(),
            ),
          )
        ],
      ),
    );
  }

  Future<dynamic> getMonthData(
    CurrentMonthReportService monthService,
    int subtractMonth,
    Color color,
  ) async {
    var month = DateFormat("MM/yyyy").parse(monthService.current.currentMonth).subtractMonth(subtractMonth);
    var priorMonth = GetIt.I<AccountabilityMonthService>(param1: month);

    var balance = await priorMonth.getBalance();
    var incomes = await priorMonth.getIncomes();
    var expenses = await priorMonth.getExpenses();

    return {
      "subtractMonth": subtractMonth,
      "title": DateFormat("MMMM yyyy", "pt_BR").format(month).capitalize(),
      "balance": balance,
      "incomes": incomes,
      "expenses": expenses,
      "color": color,
    };
  }
}
