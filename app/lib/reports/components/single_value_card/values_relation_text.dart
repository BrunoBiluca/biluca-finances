import 'package:biluca_financas/common/formatter.dart';
import 'package:biluca_financas/reports/models/values_relation.dart';
import 'package:flutter/material.dart';

class ValuesRelationText extends StatelessWidget {
  final Color positiveText = const Color(0xFF43C67C);
  final Color negativeText = const Color(0xFFF54149);
  final Color neutralText = const Color(0xFF988F81);

  final ValuesRelation values;
  const ValuesRelationText({super.key, required this.values});

  factory ValuesRelationText.withValues(
    double current,
    double related, {
    bool lessIsPositite = false,
    Key? key,
  }) {
    return ValuesRelationText(
      values: ValuesRelation(
        current,
        related,
        lessIsPositite: lessIsPositite,
      ),
      key: key,
    );
  }

  Color textColor() {
    return switch (values.type) {
      ValuesRelationType.positive => positiveText,
      ValuesRelationType.negative => negativeText,
      ValuesRelationType.neutral => neutralText,
      ValuesRelationType.unknown => neutralText,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      values.type == ValuesRelationType.unknown ? "?" : Formatter.relation(values.percentage),
      key: const Key("relação"),
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: textColor(),
            fontWeight: FontWeight.bold,
          ),
    );
  }
}
