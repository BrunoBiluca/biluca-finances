import 'package:biluca_financas/reports/components/future_handler.dart';
import 'package:biluca_financas/reports/components/icon_highlight.dart';
import 'package:biluca_financas/reports/components/single_value_card/single_value_card.dart';
import 'package:biluca_financas/reports/monthly_report_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SummaryBalanceCard extends StatelessWidget {
  const SummaryBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return futureHandler(
      MonthlyReportServiceProvider.of(context).summaryBalance(),
      (d) => SingleValueCard(
        title: "Balanço",
        currentValue: d["balance"],
        side: d["balance"] > 0
            ? const IconHighlight(
                bgColor: Color(0xFF122622),
                borderColor: Color(0xFF232428),
                txtColor: Color(0xFF43C67C),
                icon: FontAwesomeIcons.plus,
              )
            : const IconHighlight(
                bgColor: Color(0xFF24141B),
                borderColor: Color(0xFF232428),
                txtColor: Color(0xFFF54149),
                icon: FontAwesomeIcons.minus,
              ),
      ),
    );
  }
}
