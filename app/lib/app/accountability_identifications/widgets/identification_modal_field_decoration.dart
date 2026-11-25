import 'package:biluca_financas/app/themes/app_colors.dart';
import 'package:flutter/material.dart';

InputDecoration identificationModalFieldDecoration(
  BuildContext context, {
  required String labelText,
  String? hintText,
  String? errorText,
}) {
  final theme = Theme.of(context);
  final borderSide = BorderSide(color: context.appColors.modalFieldBorder);
  final focusedBorderSide =
      BorderSide(color: context.appColors.modalFocusedFieldBorder);
  final errorBorderSide = BorderSide(color: theme.colorScheme.error);
  final radius = BorderRadius.circular(8);

  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    errorText: errorText,
    filled: true,
    fillColor: theme.colorScheme.surfaceContainer,
    border: OutlineInputBorder(borderRadius: radius, borderSide: borderSide),
    enabledBorder:
        OutlineInputBorder(borderRadius: radius, borderSide: borderSide),
    focusedBorder:
        OutlineInputBorder(borderRadius: radius, borderSide: focusedBorderSide),
    errorBorder:
        OutlineInputBorder(borderRadius: radius, borderSide: errorBorderSide),
    focusedErrorBorder:
        OutlineInputBorder(borderRadius: radius, borderSide: errorBorderSide),
  );
}
