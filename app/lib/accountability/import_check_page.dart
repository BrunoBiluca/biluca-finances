import 'package:biluca_financas/accountability/components/table.dart';
import 'package:biluca_financas/accountability/services/import_service.dart';
import 'package:biluca_financas/components/base_dialog.dart';
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
    return BaseDialog(
      title: "Conferência das entradas importadas",
      content: SizedBox(
        width: 1500,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "${widget.service.entries.length} novas entradas.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 400,
                child: AccountabilityTable(
                  entries: widget.service.entries,
                  onUpdate: (updatedEntry) => setState(() {
                    var index = widget.service.entries.indexOf(updatedEntry);
                    widget.service.entries[index] = updatedEntry;
                  }),
                  onRemove: (entry) => setState(() => widget.service.entries.remove(entry)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "${widget.service.duplicatedEntries.length} entradas consideradas duplicadas.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 400,
                child: AccountabilityTable(
                  entries: widget.service.duplicatedEntries,
                  onUpdate: (updatedEntry) => setState(() {
                    var index = widget.service.duplicatedEntries.indexOf(updatedEntry);
                    widget.service.duplicatedEntries[index] = updatedEntry;
                  }),
                  onRemove: (entry) => setState(() => widget.service.cancelDuplication(entry)),
                  showInsertedAt: true,
                  removeIcon: Icons.arrow_upward_rounded,
                  removeTooltip: "Desconsiderar duplicata",
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () async {
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text("Cancelar"),
        ),
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
