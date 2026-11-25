import 'package:biluca_financas/app/themes/app_colors.dart';
import 'package:flutter/material.dart';

class IdentificationIconColorFields extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPickIcon;
  final VoidCallback onPickColor;

  const IdentificationIconColorFields({
    super.key,
    required this.icon,
    required this.color,
    required this.onPickIcon,
    required this.onPickColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = Border.all(color: context.appColors.modalFieldBorder);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ícone',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              InkWell(
                key: const Key('identification-icon-button'),
                onTap: onPickIcon,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  key: const Key('identification-icon-container'),
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                    border: border,
                  ),
                  child: Row(
                    children: [
                      Icon(icon, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Alterar ícone',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cor',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              InkWell(
                key: const Key('identification-color-button'),
                onTap: onPickColor,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  key: const Key('identification-color-container'),
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                    border: border,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
