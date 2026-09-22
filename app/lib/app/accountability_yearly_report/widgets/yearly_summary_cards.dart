import 'package:biluca_financas/app/themes/app_theme.dart';
import 'package:biluca_financas/app/themes/theme_manager.dart';
import 'package:biluca_financas/common/extensions/currency.dart';
import 'package:biluca_financas/common/formatters/formatter.dart';
import 'package:biluca_financas/common/ui/reports/summary_value_card/summary_card_label.dart';
import 'package:biluca_financas/common/ui/reports/summary_value_card/summary_card_sub_info.dart';
import 'package:flutter/material.dart';

import 'package:biluca_financas/core/accountability_yearly_report/models/yearly_summary.dart';
import 'package:biluca_financas/common/ui/reports/summary_value_card/summary_value_card.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class YearlySummaryCards extends StatelessWidget {
  final YearlySummary res;

  const YearlySummaryCards({
    super.key,
    required this.res,
  });

  @override
  Widget build(BuildContext context) {
    var appTheme = GetIt.I<ThemeManager>();
    var currTheme = appTheme.getCurrentTheme(context);

    var consolidatedMonths = 0;
    var openMonths = 0;
    var currentMonth = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
    if (res.range.end.isBefore(currentMonth)) {
      consolidatedMonths = 12;
      openMonths = 0;
    } else {
      var monthDiff = (res.range.end.difference(DateTime.now()).inDays / 30).ceil();
      consolidatedMonths = 12 - monthDiff;
      openMonths = monthDiff;
    }

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
                  Text("Resumo Operacional", style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
              Text(
                "$consolidatedMonths Competências consolidadas${openMonths > 0 ? " e $openMonths em aberto" : ""}",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          StaggeredGrid.count(
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: constraints.maxWidth < 850 ? 1 : 2,
            children: [
              buildBalanceCard(context, currTheme),
              buildBalanceAvgCard(context, currTheme),
              buildIncomesCard(context, currTheme),
              buildIncomeAvgCard(context, currTheme),
              buildOutcomesCard(context, currTheme),
              buildOutcomeAvgCard(context, currTheme),
            ]
                .map(
                  (e) => StaggeredGridTile.extent(
                    mainAxisExtent: 180,
                    crossAxisCellCount: 1,
                    child: e,
                  ),
                )
                .toList(),
          )
        ],
      ),
    );
  }

  SummaryValueCard buildOutcomeAvgCard(BuildContext context, AppTheme currTheme) {
    return SummaryValueCard(
      title: "Média mensal de despesas",
      value: res.avgExpenses,
      subInfo: SummaryCardSubInfo(
        label: "Comprometimento da Renda",
        value: "${Formatter.relationWithoutSign(res.avgExpenses / res.avgIncomes)} consolidado",
        color: currTheme.colors.negativeYield,
        bgColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(150),
      ),
    );
  }

  SummaryValueCard buildOutcomesCard(BuildContext context, AppTheme currTheme) {
    return SummaryValueCard(
      title: "Total de despesas",
      value: res.totalExpenses,
      color: currTheme.colors.negativeYield,
      subInfo: SummaryCardSubInfo(
        label: "Média mensal de despesas",
        value: "R\$ ${formatReal(res.avgExpenses)} / mês",
        color: currTheme.colors.negativeYield,
        bgColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(150),
      ),
      label: SummaryCardLabel(
        label: "Saídas",
        color: currTheme.colors.negativeYield,
        icon: Icons.arrow_downward,
        bgColor: currTheme.colors.negativeYieldBg,
      ),
    );
  }

  SummaryValueCard buildIncomeAvgCard(BuildContext context, AppTheme currTheme) {
    return SummaryValueCard(
      title: "Média mensal de receitas",
      value: res.avgIncomes,
      subInfo: SummaryCardSubInfo(
        label: "Pico Máximo",
        value: "R\$ ${formatReal(res.peakIncome)} (${res.peakIncomeMonth})",
        color: currTheme.colors.positiveYieldAlt,
        bgColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(150),
      ),
    );
  }

  SummaryValueCard buildIncomesCard(BuildContext context, AppTheme currTheme) {
    return SummaryValueCard(
      title: "Total de receitas",
      value: res.totalIncomes,
      color: currTheme.colors.positiveYieldAlt,
      subInfo: SummaryCardSubInfo(
        label: "Média mensal de receitas",
        value: "R\$ ${formatReal(res.avgIncomes)} / mês",
        color: currTheme.colors.positiveYieldAlt,
        bgColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(150),
      ),
      label: SummaryCardLabel.positiveAlt(
        label: "Entradas",
        icon: Icons.arrow_upward,
        theme: currTheme,
      ),
    );
  }

  SummaryValueCard buildBalanceAvgCard(BuildContext context, AppTheme currTheme) {
    return SummaryValueCard(
      title: "Média mensal de balanços",
      value: res.avgBalance,
      subInfo: SummaryCardSubInfo(
        label: "Índice de poupança",
        value: "${Formatter.relationWithoutSign(res.avgBalance / res.avgIncomes)} da receita",
        color: res.avgBalance > 0 ? currTheme.colors.positiveYield : currTheme.colors.negativeYield,
        bgColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(150),
      ),
    );
  }

  SummaryValueCard buildBalanceCard(BuildContext context, AppTheme currTheme) {
    return SummaryValueCard(
      title: "Balanço",
      value: res.balance,
      color: res.balance > 0 ? currTheme.colors.positiveYield : currTheme.colors.negativeYield,
      subInfo: SummaryCardSubInfo(
        label: "Média mensal",
        value: "R\$ ${NumberFormat('#,##0.00', 'de').format(res.avgBalance)} / mês",
        color: Colors.white,
        bgColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(150),
      ),
      label: res.balance > 0
          ? SummaryCardLabel(
              label: "Superávit",
              color: currTheme.colors.positiveYield,
              icon: Icons.trending_up,
              bgColor: currTheme.colors.positiveYieldBg,
            )
          : SummaryCardLabel(
              label: "Déficit",
              color: currTheme.colors.negativeYield,
              icon: Icons.trending_down,
              bgColor: currTheme.colors.negativeYieldBg,
            ),
    );
  }
}
