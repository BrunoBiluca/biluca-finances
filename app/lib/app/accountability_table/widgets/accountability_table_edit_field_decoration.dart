import 'package:flutter/material.dart';

InputDecoration accountabilityTableEditFieldDecoration(
  BuildContext context, {
  required String hintText,
  String? errorText,
  Color? fillColor,
}) {
  final theme = Theme.of(context);
  final outline = theme.colorScheme.outlineVariant.withValues(alpha: 0.5);
  final borderRadius = BorderRadius.circular(3);

  return InputDecoration(
    hintText: hintText,
    errorText: errorText,
    isDense: true,
    filled: true,
    fillColor: fillColor ?? theme.colorScheme.surfaceContainerLow,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    border: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: outline, width: 0.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: outline, width: 0.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.75),
        width: 0.75,
      ),
    ),
  );
}
