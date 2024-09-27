import 'package:biluca_financas/accountability/models/entry_request.dart';
import 'package:biluca_financas/components/forms/data_picker_field.dart';
import 'package:biluca_financas/components/forms/primary_text_field.dart';
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
            PrimaryTextField(
              labelText: 'Descrição',
              autofocus: true,
              controller: descriptionCtrl,
            ),
            const SizedBox(height: 20),
            PrimaryTextField(
              labelText: 'Valor',
              controller: valueCtrl,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            DatePickerField(
              current: createdAt,
              onSelected: (d) => setState(
                () {
                  if (d == null) return;
                  createdAt = d;
                },
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
