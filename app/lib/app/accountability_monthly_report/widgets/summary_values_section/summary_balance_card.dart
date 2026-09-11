import 'package:biluca_financas/common/formatters/formatter.dart';
import 'package:biluca_financas/common/ui/reports/future_handler.dart';
import 'package:biluca_financas/common/ui/reports/icon_highlight.dart';
import 'package:biluca_financas/common/ui/reports/report_tooltip.dart';
import 'package:biluca_financas/common/ui/reports/values_comparison_full_text.dart';
import 'package:biluca_financas/app/accountability_monthly_report/monthly_report_service.provider.dart';
import 'package:biluca_financas/common/ui/reports/consolidated_value_card.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SummaryBalanceCard extends StatelessWidget {
  const SummaryBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    var service = MonthlyReportServiceProvider.of(context);
    return futureHandler(
      Future.wait([
        service.summaryBalance(),
        service.summaryIncomes(),
        service.summaryExpenses(),
      ]),
      (d) => ConsolidatedValueCard(
        title: "Balanço",
        currentValue: d[0]["balance"],
        extraInfo: ValuesComparisonFullText.from(
          d[0]["balance"],
          d[0]["avgRecentMonts"],
          false,
          suffix: "em relação aos últimos 12 meses",
        ),
        tooltipSuffix: "mês anterior.",
        side: d[0]["balance"] > 0
            ? ReportTooltip(
                message: "Balanço positivo. Mais dinheiro entrando do que saindo.",
                verticalOffset: 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const IconHighlight(
                      bgColor: Color(0xFF122622),
                      borderColor: Color(0xFF232428),
                      txtColor: Color(0xFF43C67C),
                      icon: FontAwesomeIcons.plus,
                    ),
                    SizedBox(height: 10),
                    Text(
                      Formatter.relation(d[1]["incomes"].abs() / d[2]["expenses"].abs()),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Color(0xFF43C67C),
                            fontWeight: FontWeight.bold,
                          ),
                    )
                  ],
                ),
              )
            : ReportTooltip(
                message: "Balanço negativo. Ou gasta menos ou arruma mais dinheiro.",
                verticalOffset: 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const IconHighlight(
                      bgColor: Color(0xFF24141B),
                      borderColor: Color(0xFF232428),
                      txtColor: Color(0xFFF54149),
                      icon: FontAwesomeIcons.minus,
                    ),
                    SizedBox(height: 10),
                    Text(
                      Formatter.relation(d[1]["incomes"].abs() / d[2]["expenses"].abs()),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Color(0xFFF54149),
                            fontWeight: FontWeight.bold,
                          ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
