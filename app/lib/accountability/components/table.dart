import 'package:biluca_financas/formatter.dart';
import 'package:biluca_financas/accountability/components/identification_edit.dart';
import 'package:biluca_financas/components/number.dart';
import 'package:biluca_financas/components/number_field_edit.dart';
import 'package:biluca_financas/components/text_field_edit.dart';
import 'package:flutter/material.dart';

class AccountabilityTable extends StatelessWidget {
  final List<dynamic> entries;
  final void Function(dynamic) onUpdate;
  final void Function(dynamic) onRemove;
  final bool showInsertedAt;
  final IconData removeIcon;
  final String removeTooltip;
  const AccountabilityTable({
    super.key,
    required this.entries,
    required this.onUpdate,
    required this.onRemove,
    this.showInsertedAt = false,
    this.removeIcon = Icons.delete,
    this.removeTooltip = "Remover",
  });

  @override
  Widget build(BuildContext context) {
    return DataTable(
      headingRowColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.hovered)) {
          return Theme.of(context).colorScheme.secondary.withOpacity(0.8);
        }
        return Theme.of(context).colorScheme.secondary;
      }),
      dataRowColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.hovered)) {
          return Theme.of(context).colorScheme.tertiary.withOpacity(0.8);
        }
        return Theme.of(context).colorScheme.tertiary;
      }),
      border: TableBorder.all(color: Theme.of(context).scaffoldBackgroundColor, width: 4),
      columns: [
        showInsertedAt ? "Inserido em" : null,
        "Criação",
        "Descrição",
        "Valor",
        "Identificação",
        "",
      ].where((t) => t != null).map((t) => _dataColumn(context, t!)).toList(),
      rows: [...entries.map((entry) => _tableRow(context, entry))],
    );
  }

  DataColumn _dataColumn(BuildContext context, String text) => DataColumn(
        label: Text(
          text,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      );

  DataRow _tableRow(BuildContext context, dynamic entry) {
    List<DataCell> optionalCells = [];

    if (showInsertedAt) {
      optionalCells.add(DataCell(
        Text(
          Formatter.date(entry.insertedAt),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ));
    }

    return DataRow(
      cells: optionalCells +
          [
            DataCell(
              Text(
                Formatter.date(entry.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            DataCell(
              Text(
                entry.description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              onTap: () => editText(
                context,
                entry.description,
                (updatedText) => onUpdate(entry..description = updatedText),
              ),
            ),
            DataCell(
              Number(number: entry.value),
              onTap: () => editNumber(
                context,
                entry.value,
                (updatedNumber) => onUpdate(entry..value = updatedNumber),
              ),
            ),
            DataCell(
              AccountabilityIdentificationEdit(
                identification: entry.identification,
                onEdit: (id) => onUpdate(entry..identification = id),
              ),
            ),
            DataCell(
              Tooltip(
                message: removeTooltip,
                child: IconButton(
                  onPressed: () => onRemove(entry),
                  icon: Icon(
                    removeIcon,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ),
            ),
          ],
    );
  }
}
