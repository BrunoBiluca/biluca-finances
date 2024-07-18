import 'package:biluca_financas/accountability/bloc/bloc.dart';
import 'package:biluca_financas/accountability/bloc/events.dart';
import 'package:biluca_financas/common/formatter.dart';
import 'package:biluca_financas/accountability/components/identification_edit.dart';
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
        columns: const [
          DataColumn(label: Text('Descrição')),
          DataColumn(label: Text('Valor')),
          DataColumn(label: Text('Identificação')),
          DataColumn(label: Text('Criação')),
          DataColumn(label: Text('Data da Inserção')),
          DataColumn(label: Text('')),
        ],
        rows: [...entries.map((entry) => _tableRow(context, entry))],
      ),
    );
  }
}

DataRow _tableRow(BuildContext context, AccountabilityEntry entry) {
  return DataRow(
    cells: [
      DataCell(
        TextFieldEdit(
          text: entry.description,
          onEdit: (updatedText) =>
              context.read<AccountabilityBloc>().add(UpdateAccountabilityEntry(entry..description = updatedText)),
        ),
      ),
      DataCell(NumberFieldEdit(
        number: entry.value,
        onEdit: (updatedNumber) =>
            context.read<AccountabilityBloc>().add(UpdateAccountabilityEntry(entry..value = updatedNumber)),
      )),
      DataCell(AccountabilityIdentificationEdit(
        identification: entry.identification,
        onEdit: (id) {
          entry.identification = id;
          context.read<AccountabilityBloc>().add(UpdateAccountabilityEntry(entry));
        },
      )),
      DataCell(Text(Formatter.date(entry.createdAt))),
      DataCell(Text(Formatter.date(entry.insertedAt))),
      DataCell(
        IconButton(
          onPressed: () => {
            context.read<AccountabilityBloc>()
              ..add(
                DeleteAccountabilityEntry(entry),
              )
          },
          icon: const Icon(Icons.delete),
        ),
      ),
    ],
  );
}
