import 'package:biluca_financas/accountability/models/entry_request.dart';
import 'package:biluca_financas/common/real_input_formatter.dart';
import 'package:biluca_financas/components/forms/data_picker_field.dart';
import 'package:biluca_financas/components/forms/primary_text_field.dart';
import 'package:flutter/material.dart';

class AccountabilityEntryForm extends StatefulWidget {
  const AccountabilityEntryForm({super.key});

  @override
  State<AccountabilityEntryForm> createState() => _AccountabilityEntryFormState();
}

class _AccountabilityEntryFormState extends State<AccountabilityEntryForm> {
  var descriptionCtrl = TextEditingController();
  var valueCtrl = TextEditingController();
  var inputFormatter = RealInputFormatter();
  DateTime createdAt = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Nova entrada"),
      content: SizedBox(
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            PrimaryTextField(
              labelText: 'Descrição',
              autofocus: true,
              controller: descriptionCtrl,
              validateEmpty: true,
            ),
            const SizedBox(height: 20),
            PrimaryTextField(
              labelText: 'Valor',
              controller: valueCtrl,
              keyboardType: TextInputType.number,
              validateEmpty: true,
              formatters: [inputFormatter],
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
          onPressed: () => save(context),
          child: const Text("Salvar"),
        )
      ],
    );
  }

  void save(BuildContext context) {
    if (descriptionCtrl.text.isEmpty || valueCtrl.text.isEmpty) {
      return;
    }

    return Navigator.pop(
      context,
      AccountabilityEntryRequest(
        description: descriptionCtrl.text,
        value: inputFormatter.parse(valueCtrl.text),
        createdAt: createdAt,
      ),
    );
  }
}
