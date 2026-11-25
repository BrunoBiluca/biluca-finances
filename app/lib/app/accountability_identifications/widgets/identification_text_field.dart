import 'package:biluca_financas/app/accountability_identifications/widgets/identification_modal_field_decoration.dart';
import 'package:flutter/material.dart';

class IdentificationTextField extends StatelessWidget {
  final Key fieldKey;
  final TextEditingController controller;
  final String label;
  final String? errorText;
  final String? hintText;
  final int? minLines;
  final int? maxLines;
  final bool autofocus;
  final ValueChanged<String>? onChanged;

  const IdentificationTextField({
    super.key,
    required this.fieldKey,
    required this.controller,
    required this.label,
    this.errorText,
    this.hintText,
    this.minLines,
    this.maxLines = 1,
    this.autofocus = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: fieldKey,
      controller: controller,
      autofocus: autofocus,
      minLines: minLines,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: identificationModalFieldDecoration(
        context,
        labelText: label,
        hintText: hintText,
        errorText: errorText,
      ),
    );
  }
}
