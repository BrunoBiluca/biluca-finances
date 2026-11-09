import 'package:biluca_financas/app/accountability_table/widgets/accountability_table_edit_field_decoration.dart';
import 'package:biluca_financas/app/accountability_table/widgets/accountability_table_row.dart';
import 'package:biluca_financas/app/themes/theme_manager.dart';
import 'package:biluca_financas/common/ui/real_currency.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AccountabilityTableValueCell {
  final double value;
  final bool isEditing;
  final TextEditingController controller;
  final String? errorText;
  final int rowIndex;
  final ValueChanged<String> onChanged;
  final VoidCallback? onTap;

  const AccountabilityTableValueCell({
    required this.value,
    required this.isEditing,
    required this.controller,
    required this.errorText,
    required this.rowIndex,
    required this.onChanged,
    this.onTap,
  });

  DataCell build(BuildContext context) {
    final theme = Theme.of(context);
    return DataCell(
      isEditing
          ? TextField(
              key: Key('edit-value-$rowIndex'),
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: _valueColor(context, _editingValue),
              ),
              decoration: accountabilityTableEditFieldDecoration(
                context,
                hintText: 'Valor',
                errorText: errorText,
                fillColor: getInputFieldBackgroundColor(rowIndex),
              ),
              onChanged: onChanged,
            )
          : RealCurrency(
              number: value,
              color: _valueColor(context, value),
            ),
      onTap: isEditing ? null : onTap,
    );
  }

  double get _editingValue {
    final text = controller.text.trim();
    final normalizedValue = text.contains(',') ? text.replaceAll('.', '').replaceAll(',', '.') : text;
    final parsedValue = double.tryParse(normalizedValue);
    return parsedValue != null && parsedValue.isFinite ? parsedValue : value;
  }

  Color _valueColor(BuildContext context, double value) {
    final colors = GetIt.I<ThemeManager>().getCurrentTheme(context).colors;
    if (value > 0) return colors.positiveYield;
    if (value < 0) return colors.negativeYield;
    return colors.neutralYield;
  }
}
