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
      content: SizedBox(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextField(
              cursorColor: Colors.white,
              decoration: const InputDecoration(labelText: 'Descrição'),
              autofocus: true,
              controller: descriptionCtrl,
            ),
            const SizedBox(height: 20),
            TextField(
              cursorColor: Colors.white,
              decoration: const InputDecoration(labelText: 'Valor'),
              controller: valueCtrl,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () async {
                var date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2022),
                  lastDate: DateTime.now(),
                  currentDate: createdAt,
                );
                if (date != null) {
                  setState(() => createdAt = date);
                }
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month),
                  SizedBox(width: 20),
                  Text('Data de entrada'),
                ],
              ),
            )
          ],
        ),
      ),
      actions: [
        TextButton(
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
