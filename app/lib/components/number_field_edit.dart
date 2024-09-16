import 'package:biluca_financas/common/formatter.dart';
import 'package:biluca_financas/components/number.dart';
import 'package:flutter/material.dart';

class NumberFieldEdit extends StatelessWidget {
  final double number;
  final Function(double) onEdit;

  const NumberFieldEdit({super.key, required this.number, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => editNumber(context, number, onEdit),
      child: Number(number: number),
    );
  }
}

void editNumber(BuildContext context, double number, Function(double) onEdit) {
  var ctrl = TextEditingController(text: Formatter.number(number));
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Editar valor'),
      content: TextField(
        autofocus: true,
        controller: ctrl,
        keyboardType: TextInputType.number,
        onEditingComplete: () {
          onEdit(double.parse(ctrl.text.replaceAll(".", "").replaceAll(",", ".")));
          Navigator.pop(context);
        },
      ),
    ),
  );
}
