import 'package:biluca_financas/app/accountability_monthly_report/monthly_report_service.provider.dart';
import 'package:biluca_financas/app/themes/app_theme.dart';
import 'package:biluca_financas/app/themes/theme_manager.dart';
import 'package:biluca_financas/common/formatters/formatter.dart';
import 'package:biluca_financas/common/ui/reports/future_handler.dart';
import 'package:biluca_financas/common/ui/reports/summary_value_card/summary_card_label.dart';
import 'package:biluca_financas/common/ui/reports/summary_value_card/summary_value_card.dart';
import 'package:biluca_financas/common/ui/reports/values_comparison_full_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get_it/get_it.dart';

class SummaryValuesSection extends StatelessWidget {
  const SummaryValuesSection({super.key});

  @override
  Widget build(BuildContext context) {
    var service = MonthlyReportServiceProvider.of(context);
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
                  Icon(Icons.analytics_outlined, color: Theme.of(context).colorScheme.secondary),
                  Text(
                    "Resumo Operacional",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          FutureHandler(
            key: Key(service.current.currentMonth.toString()),
            future: Future.wait([
              service.summaryBalance(),
              service.summaryIncomes(),
              service.summaryExpenses(),
            ]),
            child: (res) => StaggeredGrid.count(
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: constraints.maxWidth < 850 ? 1 : 3,
              children: [
                buildBalanceCard(
                  res[0]["balance"],
                  res[1]["incomes"],
                  res[2]["expenses"],
                  res[0]["avgRecentMonts"],
                  currTheme,
                  context,
                ),
                buildIncomesCard(
                  res[1]["incomes"],
                  res[1]["related"],
                  res[1]["avgRecentMonts"],
                  currTheme,
                  context,
                ),
                buildExpensesCard(
                  res[2]["expenses"],
                  res[2]["related"],
                  res[2]["avgRecentMonts"],
                  currTheme,
                  context,
                )
              ]
                  .map(
                    (e) => StaggeredGridTile.extent(
                      mainAxisExtent: 200,
                      crossAxisCellCount: 1,
                      child: e,
                    ),
                  )
                  .toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget buildBalanceCard(
    double balance,
    double incomes,
    double expenses,
    double avgBalanceRecentMonths,
    AppTheme currTheme,
    BuildContext context,
  ) =>
      SummaryValueCard(
        title: "Balanço",
        value: balance,
        color: balance > 0 ? currTheme.colors.positiveYieldAlt : currTheme.colors.negativeYield,
        subInfo: ValuesComparisonFullText.from(
          balance,
          avgBalanceRecentMonths,
          false,
          suffix: "em relação aos últimos 12 meses",
        ),
        label: balance > 0
            ? SummaryCardLabel(
                label: "Superávit\n${Formatter.relationWithoutSign(balance / incomes)}",
                color: currTheme.colors.positiveYield,
                icon: Icons.trending_up,
                bgColor: currTheme.colors.positiveYieldBg,
              )
            : SummaryCardLabel(
                label: "Déficit\n${Formatter.relationWithoutSign(balance / incomes)}",
                color: currTheme.colors.negativeYield,
                icon: Icons.trending_down,
                bgColor: currTheme.colors.negativeYieldBg,
              ),
      );

  Widget buildIncomesCard(
    double incomes,
    double incomesLastMonth,
    double avgIncomesRecentMonths,
    AppTheme currTheme,
    BuildContext context,
  ) =>
      SummaryValueCard(
        title: "Receitas",
        value: incomes,
        color: currTheme.colors.positiveYield,
        subInfo: ValuesComparisonFullText.from(
          incomes,
          avgIncomesRecentMonths,
          false,
          suffix: "em relação aos últimos 12 meses",
        ),
        label: incomes > incomesLastMonth
            ? SummaryCardLabel.positive(
                label: Formatter.relationWithoutSign(1 - (incomes / incomesLastMonth)),
                icon: Icons.arrow_upward,
                theme: currTheme,
              )
            : SummaryCardLabel.negative(
                label: Formatter.relationWithoutSign(1 - (incomes / incomesLastMonth)),
                icon: Icons.arrow_downward,
                theme: currTheme,
              ),
      );

  Widget buildExpensesCard(
    double expenses,
    double expensesLastMonth,
    double avgExpensesRecentMonths,
    AppTheme currTheme,
    BuildContext context,
  ) =>
      SummaryValueCard(
        title: "Receitas",
        value: expenses,
        color: currTheme.colors.negativeYield,
        subInfo: ValuesComparisonFullText.from(
          expenses,
          avgExpensesRecentMonths,
          true,
          suffix: "em relação aos últimos 12 meses",
        ),
        label: expenses.abs() < expensesLastMonth.abs()
            ? SummaryCardLabel.positive(
                label: Formatter.relationWithoutSign(1 - (expenses / expensesLastMonth)),
                icon: Icons.arrow_downward,
                theme: currTheme,
              )
            : SummaryCardLabel.negative(
                label: Formatter.relationWithoutSign(1 - (expenses / expensesLastMonth)),
                icon: Icons.arrow_upward,
                theme: currTheme,
              ),
      );
}
