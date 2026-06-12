import 'package:biluca_financas/reports/monthly_report_v2/sections/accountability_by_identifications_section/identification_detail.dart';
import 'package:biluca_financas/reports/monthly_report_v2/sections/accountability_by_identifications_section/identifications_percentage_chart.dart';
import 'package:biluca_financas/reports/monthly_report_v2/services/identification_report_info.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class IdentificationsViewSection extends StatelessWidget {
  final List<IdentificationReportInfo> data;

  const IdentificationsViewSection(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: data.isEmpty
              ? const Text("Nenhuma identificação")
              : Column(
                  children: data
                      .sortedByCompare(
                        (i) => i.current.abs(),
                        (a, b) => b.compareTo(a),
                      )
                      .map((i) => IdentificationDetail(i))
                      .toList(),
                ),
        ),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: SizedBox(
            width: 300,
            height: 300,
            child: IdentificationsPercentageChart(data: data),
          ),
        ),
      ],
    );
  }
}
