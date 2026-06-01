import 'package:biluca_financas/accountability/models/identification.dart';
import 'package:biluca_financas/common/extensions/color_extensions.dart';
import 'package:biluca_financas/formatter.dart';
import 'package:biluca_financas/reports/components/icon_highlight.dart';
import 'package:biluca_financas/reports/components/single_value_card/values_relation_indicator.dart';
import 'package:biluca_financas/reports/components/single_value_card/values_relation_text.dart';
import 'package:biluca_financas/reports/models/values_relation.dart';
import 'package:biluca_financas/reports/monthly_report_v2/components/values_comparison_small.dart';
import 'package:biluca_financas/reports/monthly_report_v2/services/identification_rreport_info.dart';
import 'package:flutter/material.dart';

class IdentificationsViewSection extends StatelessWidget {
  final AccountabilityIdentificationType type;
  final List<IdentificationReportInfo> data;

  const IdentificationsViewSection(this.type, this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: data
                .map(
                  (i) => DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      border: Border.all(color: Theme.of(context).colorScheme.outline, width: 4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconHighlight(
                            bgColor: i.identification.color,
                            borderColor: i.identification.color,
                            txtColor: i.identification.color.adaptByLuminance(),
                            icon: i.identification.icon,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  i.identification.description,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  Formatter.value(i.current),
                                  style: Theme.of(context).textTheme.displayLarge!,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          ValuesComparisonSmall(
                            ValuesRelation(
                              i.current,
                              i.related,
                              lessIsPositite: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: const Text("Gráfico de Waffle"),
        ),
      ],
    );
  }
}
