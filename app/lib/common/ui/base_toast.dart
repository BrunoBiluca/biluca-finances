import 'package:biluca_financas/app/themes/app_colors.dart';
import 'package:flutter/material.dart';

enum BaseToastType { success, information, error }

class BaseToast extends StatelessWidget {
  final String text;
  final BaseToastType type;

  const BaseToast({
    super.key,
    required this.text,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    final textColor = switch (type) {
      BaseToastType.success => appColors.positiveYield,
      BaseToastType.information => appColors.positiveYieldAlt,
      BaseToastType.error => theme.colorScheme.error,
    };
    final icon = switch (type) {
      BaseToastType.success => Icons.check,
      BaseToastType.information => Icons.info_outline,
      BaseToastType.error => Icons.error_outline,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: theme.scaffoldBackgroundColor,
        border: Border.all(color: textColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 12.0),
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}
