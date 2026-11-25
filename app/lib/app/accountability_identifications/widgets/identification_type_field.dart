import 'package:biluca_financas/app/themes/app_colors.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification_type.dart';
import 'package:flutter/material.dart';

class IdentificationTypeField extends StatelessWidget {
  final AccountabilityIdentificationType type;
  final String? parentId;
  final String? error;
  final ValueChanged<AccountabilityIdentificationType> onChanged;

  const IdentificationTypeField({
    super.key,
    required this.type,
    required this.onChanged,
    this.parentId,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          key: const Key('identification-type-container'),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: error != null
                  ? theme.colorScheme.error
                  : context.appColors.modalFieldBorder,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<AccountabilityIdentificationType>(
              key: const Key('identification-type-field'),
              value: type,
              isExpanded: true,
              onChanged: parentId == null
                  ? (value) {
                      if (value == null) return;
                      onChanged(value);
                    }
                  : null,
              items: AccountabilityIdentificationType.values
                  .map(
                    (item) =>
                        DropdownMenuItem<AccountabilityIdentificationType>(
                      value: item,
                      child: Text(item.label),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        if (parentId != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'O tipo é herdado da categoria pai.',
              key: const Key('identification-type-helper'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              error!,
              key: const Key('identification-type-error'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
