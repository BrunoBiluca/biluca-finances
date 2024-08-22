import 'package:biluca_financas/accountability/models/entry_request.dart';
import 'package:biluca_financas/accountability/services/import_service.dart';
import 'package:biluca_financas/common/formatter.dart';
import 'package:biluca_financas/components/number_field_edit.dart';
import 'package:biluca_financas/components/text_ballon.dart';
import 'package:biluca_financas/components/text_field_edit.dart';
import 'package:flutter/material.dart';

import 'components/accountability_identification_select_dialog.dart';

class AccountabilityImportCheckPage extends StatefulWidget {
  final AccountabilityImportService service;
  const AccountabilityImportCheckPage({super.key, required this.service});

  @override
  State<StatefulWidget> createState() => _AccountabilityImportCheckPageState();
}

class _AccountabilityImportCheckPageState extends State<AccountabilityImportCheckPage> {
  DataRow _tableRow(BuildContext context, AccountabilityEntryRequest entry) {
    return DataRow(
      cells: [
        DataCell(
          TextFieldEdit(
            text: entry.description,
            onEdit: (updatedText) => setState(() => entry.description = updatedText),
          ),
        ),
        DataCell(NumberFieldEdit(
          number: entry.value,
          onEdit: (updatedNumber) => setState(() => entry.value = updatedNumber),
        )),
        DataCell(
          GestureDetector(
            onTap: () async {
              var newIdentification = await showDialog(
                  context: context, builder: (context) => const AccountabilityIdentificationSelectDialog());

              if (newIdentification == null) return;

              setState(() => entry.identification = newIdentification);
            },
            child: entry.identification == null
                ? const Text('Não identificado')
                : TextBallon(
                    text: entry.identification!.description,
                    color: entry.identification!.color,
                  ),
          ),
        ),
        DataCell(Text(Formatter.date(entry.createdAt))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Conferência das entradas importadas"),
      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Descrição')),
            DataColumn(label: Text('Valor')),
            DataColumn(label: Text('Identificação')),
            DataColumn(label: Text('Criação')),
          ],
          rows: [...widget.service.entries.map((e) => _tableRow(context, e))],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            await widget.service.save();
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text("Salvar"),
        )
      ],
    );
  }
}
