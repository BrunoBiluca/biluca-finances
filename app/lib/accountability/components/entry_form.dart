import 'package:biluca_financas/accountability/models/entry_request.dart';
import 'package:biluca_financas/common/formatter.dart';
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
              cursorColor: Theme.of(context).textTheme.labelLarge?.color,
              decoration: InputDecoration(
                labelText: 'Descrição',
                labelStyle: Theme.of(context).textTheme.labelLarge,
              ),
              autofocus: true,
              controller: descriptionCtrl,
            ),
            const SizedBox(height: 20),
            TextField(
              cursorColor: Theme.of(context).textTheme.labelLarge?.color,
              decoration: InputDecoration(
                labelText: 'Valor',
                labelStyle: Theme.of(context).textTheme.labelLarge,
              ),
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
                  currentDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => createdAt = date);
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_month,
                    color: Theme.of(context).textTheme.labelLarge?.color,
                  ),
                  const SizedBox(width: 20),
                  Text(
                    'Data de entrada',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(width: 20),
                  Text(
                    Formatter.date(createdAt),
                  ),
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
