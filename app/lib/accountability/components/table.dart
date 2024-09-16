import 'package:biluca_financas/accountability/bloc/bloc.dart';
import 'package:biluca_financas/accountability/bloc/events.dart';
import 'package:biluca_financas/common/formatter.dart';
import 'package:biluca_financas/accountability/components/identification_edit.dart';
import 'package:biluca_financas/components/number.dart';
import 'package:biluca_financas/components/number_field_edit.dart';
import 'package:biluca_financas/components/text_field_edit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/entry.dart';

class AccountabilityTable extends StatelessWidget {
  final List<AccountabilityEntry> entries;
  const AccountabilityTable({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
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
          _dataColumn(context, "Descrição"),
          _dataColumn(context, "Valor"),
          _dataColumn(context, "Identificação"),
          _dataColumn(context, "Criação"),
          _dataColumn(context, "Data da Inserção"),
          _dataColumn(context, ""),
        ],
        rows: [...entries.map((entry) => _tableRow(context, entry))],
      ),
    );
  }

  DataColumn _dataColumn(BuildContext context, String text) => DataColumn(
        label: Text(
          text,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      );

  DataRow _tableRow(BuildContext context, AccountabilityEntry entry) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            entry.description,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          onTap: () => editText(
            context,
            entry.description,
            (updatedText) => context.read<AccountabilityBloc>().add(
                  UpdateAccountabilityEntry(entry..description = updatedText),
                ),
          ),
        ),
        DataCell(
          Number(number: entry.value),
          onTap: () => editNumber(
            context,
            entry.value,
            (updatedNumber) => context.read<AccountabilityBloc>().add(
                  UpdateAccountabilityEntry(entry..value = updatedNumber),
                ),
          ),
        ),
        DataCell(
          AccountabilityIdentificationEdit(
            identification: entry.identification,
            onEdit: (id) =>
                context.read<AccountabilityBloc>().add(UpdateAccountabilityEntry(entry..identification = id)),
          ),
        ),
        DataCell(
          Text(
            Formatter.date(entry.createdAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        DataCell(
          Text(
            Formatter.date(entry.insertedAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        DataCell(
          IconButton(
            onPressed: () => {context.read<AccountabilityBloc>()..add(DeleteAccountabilityEntry(entry))},
            icon: Icon(
              Icons.delete,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
      ],
    );
  }
}
