import 'package:biluca_financas/accountability/bloc/bloc.dart';
import 'package:biluca_financas/accountability/bloc/events.dart';
import 'package:biluca_financas/common/formatter.dart';
import 'package:biluca_financas/accountability/components/identification_edit.dart';
import 'package:biluca_financas/components/text_field_edit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/entry.dart';

class AccountabilityTable extends StatelessWidget {
  final List<AccountabilityEntry> entries;
  const AccountabilityTable({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    return Table(
      children: [
        const TableRow(
          children: [
            Text('Descrição'),
            Text('Valor'),
            Text('Identificação'),
            Text('Criação'),
            Text('Data da Inserção'),
            Text(''),
          ],
        ),
        ...entries.map((entry) => tableRow(context, entry)),
      ],
    );
  }
}

TableRow tableRow(BuildContext context, AccountabilityEntry entry) {
  return TableRow(
    children: [
      TextFieldEdit(
        text: entry.description,
        onEdit: (updatedText) {
          entry.description = updatedText;
          context.read<AccountabilityBloc>().add(UpdateAccountabilityEntry(entry));
        },
      ),
      Text(Formatter.number(entry.value)),
      AccountabilityIdentificationEdit(
        identification: entry.identification,
        onEdit: (id) {
          entry.identification = id;
          context.read<AccountabilityBloc>().add(UpdateAccountabilityEntry(entry));
        },
      ),
      Text(Formatter.date(entry.createdAt)),
      Text(Formatter.date(entry.insertedAt)),
      IconButton(
        onPressed: () => {
          context.read<AccountabilityBloc>()
            ..add(
              DeleteAccountabilityEntry(entry),
            )
        },
        icon: const Icon(Icons.delete),
      ),
    ],
  );
}
