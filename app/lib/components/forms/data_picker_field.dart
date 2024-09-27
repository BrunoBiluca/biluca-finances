import 'package:biluca_financas/formatter.dart';
import 'package:flutter/material.dart';

class DatePickerField extends StatefulWidget {
  final DateTime current;
  final Function(DateTime?) onSelected;
  const DatePickerField({super.key, required this.onSelected, required this.current});

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  @override
  Widget build(BuildContext context) {
    var style = Theme.of(context).textTheme.titleMedium;

    return OutlinedButton(
      onPressed: () async {
        var date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2022),
            lastDate: DateTime.now(),
            currentDate: widget.current);

        widget.onSelected(date);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month,
            color: style?.color,
          ),
          const SizedBox(width: 20),
          Text(
            'Data de entrada',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(width: 20),
          Text(
            Formatter.date(widget.current),
          ),
        ],
      ),
    );
  }
}
