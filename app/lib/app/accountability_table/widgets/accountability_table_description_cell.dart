import 'package:biluca_financas/app/accountability_table/widgets/accountability_table_edit_field_decoration.dart';
import 'package:biluca_financas/app/accountability_table/widgets/accountability_table_row.dart';
import 'package:flutter/material.dart';

class AccountabilityTableDescriptionCell {
  final String description;
  final bool isEditing;
  final TextEditingController controller;
  final int rowIndex;
  final VoidCallback? onTap;

  const AccountabilityTableDescriptionCell({
    required this.description,
    required this.isEditing,
    required this.controller,
    required this.rowIndex,
    this.onTap,
  });

  DataCell build(BuildContext context) {
    final theme = Theme.of(context);
    return DataCell(
      isEditing
          ? TextField(
              key: Key('edit-description-$rowIndex'),
              controller: controller,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              decoration: accountabilityTableEditFieldDecoration(
                context,
                hintText: 'Descrição',
                fillColor: getInputFieldBackgroundColor(rowIndex),
              ),
            )
          : Text(
              description,
              style: theme.textTheme.bodyMedium,
            ),
      onTap: isEditing ? null : onTap,
    );
  }
}
