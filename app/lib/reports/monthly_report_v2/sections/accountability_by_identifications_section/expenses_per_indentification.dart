import 'package:biluca_financas/reports/components/future_handler.dart';
import 'package:biluca_financas/reports/monthly_report_v2/sections/accountability_by_identifications_section/identifications_view_section.dart';
import 'package:biluca_financas/reports/monthly_report_v2/services/current_month_report.service.dart';
import 'package:biluca_financas/reports/monthly_report_v2/services/identification_report_info.dart';
import 'package:flutter/material.dart';

class ExpensesPerIndentification extends StatelessWidget {
  const ExpensesPerIndentification({
    super.key,
    required CurrentMonthReportService service,
  }) : _service = service;

  final CurrentMonthReportService _service;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Despesas por identificação",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),
        futureHandler(
          _service.expensesByIdentification(),
          (data) => IdentificationsViewSection(
            data as List<IdentificationReportInfo>,
          ),
        ),
      ],
    );
  }
}
