import 'package:biluca_financas/app/accountability_table/accountability_table.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:flutter/material.dart';

class AccountabilityImportTableTab extends StatelessWidget {
  final Key tableKey;
  final List<dynamic> entries;
  final List<AccountabilityIdentification> identifications;
  final ValueChanged<dynamic> onUpdate;
  final ValueChanged<dynamic> onRemove;
  final bool showInsertedAt;
  final IconData removeIcon;
  final String removeTooltip;

  const AccountabilityImportTableTab({
    super.key,
    required this.tableKey,
    required this.entries,
    required this.identifications,
    required this.onUpdate,
    required this.onRemove,
    this.showInsertedAt = false,
    this.removeIcon = Icons.delete_outline,
    this.removeTooltip = 'Remover',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AccountabilityTable(
        key: tableKey,
        entries: entries,
        onUpdate: onUpdate,
        onRemove: onRemove,
        showInsertedAt: showInsertedAt,
        removeIcon: removeIcon,
        removeTooltip: removeTooltip,
        enableInlineEditing: true,
        identifications: identifications,
      ),
    );
  }
}
