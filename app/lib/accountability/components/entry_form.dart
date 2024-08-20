import 'package:biluca_financas/accountability/models/entry_request.dart';
import 'package:flutter/material.dart';

class AccountabilityEntryForm extends StatefulWidget {
  const AccountabilityEntryForm({super.key});

  @override
  State<AccountabilityEntryForm> createState() => _AccountabilityEntryFormState();
}

class _AccountabilityEntryFormState extends State<AccountabilityEntryForm> {
  late TextEditingController descriptionCtrl = TextEditingController();
  late TextEditingController valueCtrl = TextEditingController();
  DateTime createdAt = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Nova entrada"),
      content: Column(
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Descrição'),
            autofocus: true,
            controller: descriptionCtrl,
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Valor'),
            controller: valueCtrl,
            keyboardType: TextInputType.number,
          ),
          ElevatedButton(
            onPressed: () async {
              var date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2022),
                lastDate: DateTime.now(),
                currentDate: createdAt,
              );
              setState(() {
                createdAt = date!;
              });
            },
            child: const Text("Data da entrada"),
          )
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(
            context,
            AccountabilityEntryRequest(
              description: descriptionCtrl.text,
              value: double.parse(valueCtrl.text),
              createdAt: createdAt,
            ),
          ),
          child: const Text("Salvar"),
        )
      ],
    );
  }
}
