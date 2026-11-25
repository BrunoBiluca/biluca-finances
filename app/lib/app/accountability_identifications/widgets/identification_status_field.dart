import 'package:biluca_financas/app/accountability_identifications/widgets/identification_status_option.dart';
import 'package:flutter/material.dart';

class IdentificationStatusField extends StatelessWidget {
  final bool discontinued;
  final String? error;
  final ValueChanged<bool> onChanged;

  const IdentificationStatusField({
    super.key,
    required this.discontinued,
    required this.onChanged,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status de operação',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: IdentificationStatusOption(
                key: const Key('identification-status-active'),
                label: 'Ativa',
                description: 'Disponível para novos lançamentos',
                icon: Icons.check_circle_outline,
                color: theme.colorScheme.secondary,
                selected: !discontinued,
                hasError: error != null,
                onTap: () => onChanged(false),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: IdentificationStatusOption(
                key: const Key('identification-status-discontinued'),
                label: 'Descontinuada',
                description: 'Somente leitura no histórico',
                icon: Icons.archive_outlined,
                color: theme.colorScheme.tertiary,
                selected: discontinued,
                hasError: error != null,
                onTap: () => onChanged(true),
              ),
            ),
          ],
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              error!,
              key: const Key('identification-status-error'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
