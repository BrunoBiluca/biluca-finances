import 'package:biluca_financas/components/base_dialog.dart';
import 'package:flutter/material.dart';

class TextFieldEdit extends StatelessWidget {
  final String text;
  final Function(String) onEdit;

  const TextFieldEdit({super.key, required this.text, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => editText(context, text, onEdit),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

void editText(BuildContext context, String text, Function(String) onEdit) {
  TextEditingController ctrl = TextEditingController(text: text);
  showDialog(
    context: context,
    builder: (context) => BaseDialog(
      title: 'Editar Texto',
      content: TextField(
        autofocus: true,
        controller: ctrl,
        cursorColor: Colors.white,
        onEditingComplete: () {
          onEdit(ctrl.text);
          Navigator.pop(context);
        },
      ),
    ),
  );
}
