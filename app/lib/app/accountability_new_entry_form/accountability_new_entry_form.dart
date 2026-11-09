import 'package:biluca_financas/core/accountability/models/accountability_entry_request.dart';
import 'package:biluca_financas/core/accountability/validators/real_input_formatter.dart';
import 'package:biluca_financas/common/ui/base_dialog.dart';
import 'package:biluca_financas/common/ui/forms/data_picker_field.dart';
import 'package:biluca_financas/common/ui/forms/primary_text_field.dart';
import 'package:flutter/material.dart';

class AccountabilityEntryForm extends StatefulWidget {
  const AccountabilityEntryForm({super.key});

  @override
  State<AccountabilityEntryForm> createState() =>
      _AccountabilityEntryFormState();
}

class _AccountabilityEntryFormState extends State<AccountabilityEntryForm> {
  final descriptionCtrl = TextEditingController();
  final valueCtrl = TextEditingController();
  final inputFormatter = RealInputFormatter();
  DateTime createdAt = DateTime.now();
  String? descriptionError;
  String? valueError;
  String? dateError;

  @override
  void dispose() {
    descriptionCtrl.dispose();
    valueCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: "Nova entrada",
      content: SizedBox(
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            PrimaryTextField(
              labelText: 'Descrição',
              autofocus: true,
              controller: descriptionCtrl,
              externalErrorText: descriptionError,
              onChanged: (value) {
                if (value.trim().isNotEmpty && descriptionError != null) {
                  setState(() => descriptionError = null);
                }
              },
            ),
            const SizedBox(height: 20),
            PrimaryTextField(
              labelText: 'Valor',
              controller: valueCtrl,
              keyboardType: TextInputType.number,
              externalErrorText: valueError,
              formatters: [inputFormatter],
              onChanged: (value) {
                if (_parseValue(value) != null && valueError != null) {
                  setState(() => valueError = null);
                }
              },
            ),
            const SizedBox(height: 20),
            DatePickerField(
              current: createdAt,
              onSelected: (d) => setState(
                () {
                  if (d == null) return;
                  createdAt = d;
                  dateError = null;
                },
              ),
            ),
            if (dateError != null)
              Text(
                dateError!,
                key: const Key('entry-date-error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
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
    final description = descriptionCtrl.text.trim();
    final valueText = valueCtrl.text.trim();
    final value = _parseValue(valueText);
    final today = DateTime.now();
    final entryDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
    final firstAllowedDate = DateTime(2022);
    final lastAllowedDate = DateTime(today.year, today.month, today.day);
    final validDate = !entryDate.isBefore(firstAllowedDate) &&
        !entryDate.isAfter(lastAllowedDate);

    setState(() {
      descriptionError =
          description.isEmpty ? 'Preencha o campo, por favor' : null;
      valueError = valueText.isEmpty
          ? 'Preencha o campo, por favor'
          : value == null
              ? 'Informe um valor válido'
              : null;
      dateError = validDate ? null : 'Informe uma data válida';
    });

    if (descriptionError != null || valueError != null || dateError != null) {
      return;
    }

    return Navigator.pop(
      context,
      AccountabilityEntryRequest(
        description: description,
        value: value!,
        createdAt: createdAt,
      ),
    );
  }

  double? _parseValue(String value) {
    if (value.trim().isEmpty) return null;

    try {
      final parsed = inputFormatter.parse(value);
      return parsed.isFinite ? parsed : null;
    } on FormatException {
      return null;
    }
  }
}
