import 'package:biluca_financas/accountability/models/identification.dart';
import 'package:biluca_financas/common/color_extensions.dart';
import 'package:biluca_financas/common/data/grouped_by.dart';
import 'package:biluca_financas/components/indicator.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class IdentificationsByPie extends StatelessWidget {
  final Map<int, List<GroupedBy<AccountabilityIdentification>>> groups;

  const IdentificationsByPie._(this.groups, Key? key) : super(key: key);

  factory IdentificationsByPie({
    required List<GroupedBy<AccountabilityIdentification>> accountabilityByIdentification,
    Key? key,
  }) {
    var groups = accountabilityByIdentification
        .groupListsBy((identification) => identification.field.id)
        .values
        .sorted((g1, g2) => g2[0].total.abs().compareTo(g1[0].total.abs()))
        .asMap()
        .map((index, group) => MapEntry(index, group));

    return IdentificationsByPie._(groups, key);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: PieChart(
              PieChartData(
                borderData: FlBorderData(
                  show: false,
                ),
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: sections(),
              ),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: indicators(),
        )
      ],
    );
  }

  List<PieChartSectionData> sections() {
    return groups.values.mapIndexed(
      (index, group) {
        var color = group[0].field.color;
        var current = group[0].total.abs();

        return PieChartSectionData(
          color: color,
          titleStyle: TextStyle(color: color.adaptByLuminance()),
          value: current.truncateToDouble(),
        );
      },
    ).toList();
  }

  List<Indicator> indicators() {
    return groups.values.mapIndexed(
      (index, group) {
        var desc = group[0].field.description;
        var color = group[0].field.color;

        return Indicator(
          color: color,
          text: desc,
          isSquare: true,
        );
      },
    ).toList();
  }
}
