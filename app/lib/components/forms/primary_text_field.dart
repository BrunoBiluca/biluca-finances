import 'package:flutter/material.dart';

class PrimaryTextField extends StatelessWidget {
  final String labelText;
  final bool autofocus;
  final TextEditingController? controller;
  final Function()? onEditingComplete;
  final TextInputType? keyboardType;
  const PrimaryTextField({
    super.key,
    required this.labelText,
    this.autofocus = false,
    this.controller,
    this.keyboardType,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    var style = Theme.of(context).textTheme.titleMedium;

    return TextField(
      cursorColor: style?.color,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: style,
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: style?.color ?? Colors.white),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: style?.color ?? Colors.white),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: style?.color ?? Colors.white,
          ),
        ),
      ),
      autofocus: autofocus,
      controller: controller,
      keyboardType: keyboardType,
      onEditingComplete: onEditingComplete,
    );
  }
}
