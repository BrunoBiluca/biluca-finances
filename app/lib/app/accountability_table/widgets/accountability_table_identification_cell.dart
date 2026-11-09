import 'package:biluca_financas/app/accountability_table/widgets/accountability_identification_label.dart';
import 'package:biluca_financas/app/accountability_table/widgets/accountability_table_row.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:flutter/material.dart';

class AccountabilityTableIdentificationCell {
  final AccountabilityIdentification? identification;
  final bool isEditing;
  final int rowIndex;
  final String? draftIdentificationId;
  final List<AccountabilityIdentification> identifications;
  final ValueChanged<String?> onChanged;
  final Function onEdit;

  const AccountabilityTableIdentificationCell({
    required this.identification,
    required this.isEditing,
    required this.rowIndex,
    required this.draftIdentificationId,
    required this.identifications,
    required this.onChanged,
    required this.onEdit,
  });

  DataCell build(BuildContext context) {
    return DataCell(
      Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.all(isEditing ? 4 : 8),
          child: isEditing
              ? _identificationDropdown(context)
              : AccountabilityIdentificationLabel(
                  identification: identification,
                  onEdit: onEdit,
                ),
        ),
      ),
    );
  }

  Widget _identificationDropdown(BuildContext context) {
    final identificationIds = identifications.map((item) => item.id).toSet();
    final value = identificationIds.contains(draftIdentificationId) ? draftIdentificationId : null;

    return DropdownButton<String?>(
      key: Key('edit-identification-$rowIndex'),
      value: value,
      isExpanded: true,
      items: [
        DropdownMenuItem<String?>(
          value: null,
          child: _identificationOption(
            context,
            key: const Key('identification-option-none'),
            icon: Icons.help_outline,
            description: 'Não identificado',
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            isUnidentified: true,
          ),
        ),
        ...identifications.map(
          (item) => DropdownMenuItem<String?>(
            value: item.id,
            child: _identificationOption(
              context,
              key: Key('identification-option-${item.id}'),
              icon: item.icon,
              description: item.description,
              color: item.color,
            ),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }

  Widget _identificationOption(
    BuildContext context, {
    required Key key,
    required IconData icon,
    required String description,
    required Color color,
    bool isUnidentified = false,
  }) {
    final theme = Theme.of(context);
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isUnidentified ? theme.colorScheme.surfaceContainerHigh : getInputFieldBackgroundColor(rowIndex),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          width: .5,
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isUnidentified ? theme.colorScheme.onSurfaceVariant : color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
