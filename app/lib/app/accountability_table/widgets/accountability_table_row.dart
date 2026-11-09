import 'package:biluca_financas/app/accountability_table/widgets/accountability_table_actions_cell.dart';
import 'package:biluca_financas/app/accountability_table/widgets/accountability_table_date_cell.dart';
import 'package:biluca_financas/app/accountability_table/widgets/accountability_table_description_cell.dart';
import 'package:biluca_financas/app/accountability_table/widgets/accountability_table_identification_cell.dart';
import 'package:biluca_financas/app/accountability_table/widgets/accountability_table_value_cell.dart';
import 'package:biluca_financas/common/formatters/formatter.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

class AccountabilityTableRow {
  final dynamic entry;
  final int rowIndex;
  final bool showInsertedAt;
  final bool enableInlineEditing;
  final bool isEditing;
  final IconData removeIcon;
  final String removeTooltip;
  final TextEditingController descriptionController;
  final TextEditingController valueController;
  final String? valueError;
  final String? draftIdentificationId;
  final List<AccountabilityIdentification> identifications;
  final VoidCallback? onDescriptionTap;
  final VoidCallback? onValueTap;
  final ValueChanged<String> onValueChanged;
  final ValueChanged<String?> onIdentificationChanged;
  final Function onIdentificationEdit;
  final VoidCallback onStartEditing;
  final VoidCallback onSaveEditing;
  final VoidCallback onCancelEditing;
  final VoidCallback onRemove;

  const AccountabilityTableRow({
    required this.entry,
    required this.rowIndex,
    required this.showInsertedAt,
    required this.enableInlineEditing,
    required this.isEditing,
    required this.removeIcon,
    required this.removeTooltip,
    required this.descriptionController,
    required this.valueController,
    required this.valueError,
    required this.draftIdentificationId,
    required this.identifications,
    required this.onValueChanged,
    required this.onIdentificationChanged,
    required this.onIdentificationEdit,
    required this.onStartEditing,
    required this.onSaveEditing,
    required this.onCancelEditing,
    required this.onRemove,
    this.onDescriptionTap,
    this.onValueTap,
  });

  DataRow2 build(BuildContext context) {
    final cells = <DataCell>[];
    if (showInsertedAt) {
      cells.add(
        DataCell(
          AccountabilityTableDateCell(
            date: Formatter.date(entry.insertedAt),
            isEditing: isEditing,
          ),
        ),
      );
    }

    cells.addAll([
      DataCell(
        AccountabilityTableDateCell(
          date: Formatter.date(entry.createdAt),
          isEditing: isEditing && !showInsertedAt,
        ),
      ),
      AccountabilityTableDescriptionCell(
        description: entry.descriptionAlt ?? entry.description,
        isEditing: isEditing,
        controller: descriptionController,
        rowIndex: rowIndex,
        onTap: onDescriptionTap,
      ).build(context),
      AccountabilityTableValueCell(
        value: entry.value,
        isEditing: isEditing,
        controller: valueController,
        errorText: valueError,
        rowIndex: rowIndex,
        onChanged: onValueChanged,
        onTap: onValueTap,
      ).build(context),
      AccountabilityTableIdentificationCell(
        identification: entry.identification,
        isEditing: isEditing,
        rowIndex: rowIndex,
        draftIdentificationId: draftIdentificationId,
        identifications: identifications,
        onChanged: onIdentificationChanged,
        onEdit: onIdentificationEdit,
      ).build(context),
      AccountabilityTableActionsCell(
        rowIndex: rowIndex,
        enableInlineEditing: enableInlineEditing,
        isEditing: isEditing,
        removeIcon: removeIcon,
        removeTooltip: removeTooltip,
        onEdit: onStartEditing,
        onSave: onSaveEditing,
        onCancel: onCancelEditing,
        onRemove: onRemove,
      ).build(context),
    ]);

    return DataRow2(
      specificRowHeight: isEditing ? (valueError == null ? 72 : 88) : null,
      color: WidgetStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(WidgetState.hovered)) {
            return Theme.of(context).colorScheme.surfaceContainerHigh;
          }
          return rowIndex.isOdd ? const Color(0xFF0A0E17) : Colors.transparent;
        },
      ),
      cells: cells,
    );
  }
}

Color getInputFieldBackgroundColor(int rowIndex) {
  return !rowIndex.isOdd ? const Color(0xFF0A0E17) : const Color(0xFF1C1F29);
}
