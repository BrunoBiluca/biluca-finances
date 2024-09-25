import 'package:biluca_financas/accountability/components/table.dart';
import 'package:biluca_financas/accountability/services/import_service.dart';
import 'package:flutter/material.dart';

class AccountabilityImportCheckPage extends StatefulWidget {
  final AccountabilityImportService service;
  const AccountabilityImportCheckPage({super.key, required this.service});

  @override
  State<StatefulWidget> createState() => _AccountabilityImportCheckPageState();
}

class _AccountabilityImportCheckPageState extends State<AccountabilityImportCheckPage> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Conferência das entradas importadas"),
      content: AccountabilityTable(
        entries: widget.service.entries,
        onUpdate: (updatedEntry) => setState(() {
          var index = widget.service.entries.indexOf(updatedEntry);
          widget.service.entries[index] = updatedEntry;
        }),
        onRemove: (entry) => setState(() => widget.service.entries.remove(entry)),
      ),
      actions: [
        TextButton(
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
