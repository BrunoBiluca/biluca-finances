import 'package:flutter/material.dart';

class TextFieldEdit extends StatelessWidget {
  final String text;
  final Function(String) onEdit;

  const TextFieldEdit({super.key, required this.text, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        TextEditingController ctrl = TextEditingController(text: text);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Editar Texto'),
            content: TextField(
              autofocus: true,
              controller: ctrl,
              onEditingComplete: () {
                onEdit(ctrl.text);
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
      child: Text(text),
    );
  }
}
