import 'dart:math';

import 'package:biluca_financas/formatter.dart';
import 'package:biluca_financas/reports/models/values_relation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ValuesComparisonSmall extends StatelessWidget {
  final ValuesRelation values;
  final String? label;
  const ValuesComparisonSmall(this.values, {super.key, this.label});

  @override
  Widget build(BuildContext context) {
    var theme = switch (values.type) {
      ValuesRelationType.negative => negativeTheme(values),
      ValuesRelationType.positive => positiveTheme(values),
      ValuesRelationType.neutral => neutralTheme(values),
      ValuesRelationType.unknown => neutralTheme(values)..["icon"] = Icons.question_mark,
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outline,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme["bgColor"],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                Transform.rotate(
                    angle: theme["rotation"],
                    child: Icon(
                      theme["icon"],
                      color: theme["txtColor"],
                      size: Theme.of(context).textTheme.bodySmall!.fontSize,
                    )),
                const SizedBox(width: 8),
                Text(
                  values.type == ValuesRelationType.unknown ? "?" : Formatter.relation(values.percentage),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: theme["txtColor"],
                        fontWeight: FontWeight.bold,
                      ),
                ),
                label != null ? const SizedBox(width: 8) : Container(),
                label != null
                    ? Text(
                        label!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: theme["txtColor"],
                              fontWeight: FontWeight.bold,
                            ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

dynamic positiveTheme(ValuesRelation values) => {
      "rotation": pi / 8,
      "bgColor": const Color(0xFF122622),
      "txtColor": const Color(0xFF43C67C),
      "icon": values.percentage > 0 ? Icons.keyboard_double_arrow_up : Icons.keyboard_double_arrow_down,
    };

dynamic neutralTheme(ValuesRelation values) => {
      "rotation": 0.0,
      "bgColor": const Color(0xFF232428),
      "txtColor": const Color(0xFF988F81),
      "icon": FontAwesomeIcons.equals,
    };

dynamic negativeTheme(ValuesRelation values) => {
      "rotation": pi / 8,
      "bgColor": const Color(0xFF24141B),
      "txtColor": const Color(0xFFF54149),
      "icon": values.percentage > 0 ? Icons.keyboard_double_arrow_up : Icons.keyboard_double_arrow_down,
    };
