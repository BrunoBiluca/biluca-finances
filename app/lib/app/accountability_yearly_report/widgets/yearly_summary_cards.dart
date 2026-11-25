import 'package:biluca_financas/app/themes/app_colors.dart';

import 'package:biluca_financas/common/extensions/currency.dart';
import 'package:biluca_financas/common/formatters/formatter.dart';
import 'package:biluca_financas/common/lib/safe_ratio.dart';
import 'package:biluca_financas/common/ui/reports/summary_value_card/summary_card_label.dart';
import 'package:flutter/material.dart';

import 'package:biluca_financas/core/accountability_yearly_report/models/yearly_summary.dart';
import 'package:biluca_financas/common/ui/reports/summary_value_card/summary_value_card.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:intl/intl.dart';

class YearlySummaryCards extends StatelessWidget {
  final YearlySummary res;

  const YearlySummaryCards({
    super.key,
    required this.res,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    

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
              buildBalanceCard(context, colors),
              buildBalanceAvgCard(context, colors),
              buildIncomesCard(context, colors),
              buildIncomeAvgCard(context, colors),
              buildOutcomesCard(context, colors),
              buildOutcomeAvgCard(context, colors),
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

  SummaryValueCard buildOutcomeAvgCard(BuildContext context, AppColors colors) {
    final ratio = safeRatio(res.avgExpenses, res.avgIncomes);
    final commitment =
        ratio == null ? "N/A" : Formatter.relationWithoutSign(ratio);

    return SummaryValueCard(
      title: "Média mensal de despesas",
      value: res.avgExpenses,
      subInfo: buildSubInfoText(
        label: "Comprometimento da Renda",
        value: "$commitment consolidado",
        color: colors.negativeYield,
        context: context,
      ),
    );
  }

  SummaryValueCard buildOutcomesCard(BuildContext context, AppColors colors) {
    return SummaryValueCard(
      title: "Total de despesas",
      value: res.totalExpenses,
      color: colors.negativeYield,
      subInfo: buildSubInfoText(
        label: "Média mensal de despesas",
        value: "R\$ ${formatReal(res.avgExpenses)} / mês",
        color: colors.negativeYield,
        context: context,
      ),
      label: SummaryCardLabel(
        label: "Saídas",
        color: colors.negativeYield,
        icon: Icons.arrow_downward,
        bgColor: colors.negativeYieldBg,
      ),
    );
  }

  SummaryValueCard buildIncomeAvgCard(BuildContext context, AppColors colors) {
    return SummaryValueCard(
      title: "Média mensal de receitas",
      value: res.avgIncomes,
      subInfo: buildSubInfoText(
        label: "Pico Máximo",
        value: "R\$ ${formatReal(res.peakIncome)} (${res.peakIncomeMonth})",
        color: colors.positiveYieldAlt,
        context: context,
      ),
    );
  }

  SummaryValueCard buildIncomesCard(BuildContext context, AppColors colors) {
    return SummaryValueCard(
      title: "Total de receitas",
      value: res.totalIncomes,
      color: colors.positiveYieldAlt,
      subInfo: buildSubInfoText(
        label: "Média mensal de receitas",
        value: "R\$ ${formatReal(res.avgIncomes)} / mês",
        color: colors.positiveYieldAlt,
        context: context,
      ),
      label: SummaryCardLabel.positiveAlt(
        label: "Entradas",
        icon: Icons.arrow_upward,
        colors: colors,
      ),
    );
  }

  SummaryValueCard buildBalanceAvgCard(BuildContext context, AppColors colors) {
    final ratio = safeRatio(res.avgBalance, res.avgIncomes);
    final savingsIndex =
        ratio == null ? "N/A" : Formatter.relationWithoutSign(ratio);

    return SummaryValueCard(
      title: "Média mensal de balanços",
      value: res.avgBalance,
      subInfo: buildSubInfoText(
        label: "Índice de poupança",
        value: "$savingsIndex da receita",
        color: res.avgBalance > 0 ? colors.positiveYield : colors.negativeYield,
        context: context,
      ),
    );
  }

  SummaryValueCard buildBalanceCard(BuildContext context, AppColors colors) {
    return SummaryValueCard(
      title: "Balanço",
      value: res.balance,
      color: res.balance > 0 ? colors.positiveYield : colors.negativeYield,
      subInfo: buildSubInfoText(
        label: "Média mensal",
        value: "R\$ ${NumberFormat('#,##0.00', 'de').format(res.avgBalance)} / mês",
        color: Colors.white,
        context: context,
      ),
      label: res.balance > 0
          ? SummaryCardLabel(
              label: "Superávit",
              color: colors.positiveYield,
              icon: Icons.trending_up,
              bgColor: colors.positiveYieldBg,
            )
          : SummaryCardLabel(
              label: "Déficit",
              color: colors.negativeYield,
              icon: Icons.trending_down,
              bgColor: colors.negativeYieldBg,
            ),
    );
  }

  Widget buildSubInfoText({
    required BuildContext context,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      spacing: 10,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }
}
