import 'package:biluca_financas/reports/monthly_report_v2/sections/accountability_by_identifications_section/identification_detail.dart';
import 'package:biluca_financas/reports/monthly_report_v2/sections/accountability_by_identifications_section/identifications_barchart.dart';
import 'package:biluca_financas/reports/monthly_report_v2/sections/accountability_by_identifications_section/identifications_percentage_chart.dart';
import 'package:biluca_financas/reports/monthly_report_v2/services/identification_report_info.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class IdentificationsViewSection extends StatelessWidget {
  final List<IdentificationReportInfo> data;

  const IdentificationsViewSection(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return data.isEmpty
        ? const Text("Nenhuma identificação")
        : Column(
            children: [
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 600,
                  mainAxisExtent: 180,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                ),
                children: data
                    .sortedByCompare(
                      (i) => i.current.abs(),
                      (a, b) => b.compareTo(a),
                    )
                    .map((i) => IdentificationDetail(i))
                    .toList(),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 300,
                      child: IdentificationsBarChart(data: data),
                    ),
                  ),
                  const SizedBox(width: 40),
                  IdentificationsPercentageChart(data: data),
                ],
              ),
            ],
          );
  }
}
