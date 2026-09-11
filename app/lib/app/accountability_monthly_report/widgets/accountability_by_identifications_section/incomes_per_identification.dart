import 'package:biluca_financas/common/ui/reports/future_handler.dart';
import 'package:biluca_financas/app/accountability_monthly_report/widgets/accountability_by_identifications_section/identifications_view_section.dart';
import 'package:biluca_financas/core/accountability_monthly_report/services/current_month_report.service.dart';
import 'package:biluca_financas/core/accountability_monthly_report/models/identification_report_info.dart';
import 'package:flutter/material.dart';

class IncomesPerIdentification extends StatelessWidget {
  const IncomesPerIdentification({
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
          "Receitas por identificação",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),
        futureHandler(
          _service.incomesByIdentification(),
          (data) => IdentificationsViewSection(
            data as List<IdentificationReportInfo>,
          ),
        ),
      ],
    );
  }
}
