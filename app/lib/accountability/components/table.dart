import 'package:biluca_financas/formatter.dart';
import 'package:biluca_financas/accountability/components/identification_edit.dart';
import 'package:biluca_financas/components/number.dart';
import 'package:biluca_financas/components/number_field_edit.dart';
import 'package:biluca_financas/components/text_field_edit.dart';
import 'package:data_table_2/data_table_2.dart';
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
    var columnStyle = Theme.of(context).textTheme.headlineSmall!;

    var columns = [
      _dataColumn("Criação", columnStyle, ColumnSize.S),
      _dataColumn("Descrição", columnStyle, ColumnSize.L),
      _dataColumn("Valor", columnStyle, ColumnSize.S),
      _dataColumn("Identificação", columnStyle, ColumnSize.S),
      _dataColumn("", columnStyle, ColumnSize.S),
    ];

    if (showInsertedAt) {
      columns.insert(0, _dataColumn("Inserido em", columnStyle, ColumnSize.S));
    }

    return DataTable2(
      scrollController: ScrollController(),
      isHorizontalScrollBarVisible: false,
      empty: Text("Nenhum registro encontrado", style: Theme.of(context).textTheme.bodySmall),
      showBottomBorder: false,
      dividerThickness: 0,
      headingRowColor: rowColor(Theme.of(context).colorScheme.secondary),
      dataRowColor: rowColor(Theme.of(context).colorScheme.tertiary),
      border: TableBorder.all(color: Theme.of(context).scaffoldBackgroundColor, width: 4),
      columns: columns,
      rows: [...entries.map((entry) => _tableRow(context, entry))],
    );
  }

  WidgetStateProperty<Color?> rowColor(Color c) {
    return WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
      if (states.contains(WidgetState.hovered)) {
        return c.withOpacity(0.8);
      }
      return c;
    });
  }

  DataColumn _dataColumn(
    String text,
    TextStyle style,
    ColumnSize size,
  ) =>
      DataColumn2(
        size: size,
        label: Text(
          text,
          style: style.copyWith(fontWeight: FontWeight.bold),
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
              RealCurrency(number: entry.value),
              onTap: () => editNumber(
                context,
                entry.value,
                (updatedNumber) => onUpdate(entry..value = updatedNumber),
              ),
            ),
            DataCell(
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AccountabilityIdentificationEdit(
                    identification: entry.identification,
                    onEdit: (id) => onUpdate(entry..identification = id),
                  ),
                ),
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
