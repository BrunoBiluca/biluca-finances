import 'package:biluca_financas/app/themes/app_colors.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:flutter/material.dart';

class IdentificationParentField extends StatelessWidget {
  final List<AccountabilityIdentification> parents;
  final String? parentId;
  final String? error;
  final bool hasChildren;
  final ValueChanged<String?> onChanged;

  const IdentificationParentField({
    super.key,
    required this.parents,
    required this.onChanged,
    this.parentId,
    this.error,
    this.hasChildren = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Categoria pai',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '1 nível máximo',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          key: const Key('identification-parent-container'),
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
            child: DropdownButton<String?>(
              key: const Key('identification-parent-field'),
              value: parentId,
              isExpanded: true,
              onChanged: hasChildren ? null : onChanged,
              selectedItemBuilder: (context) => [
                _parentOption(
                  context,
                  null,
                  key: const Key('identification-parent-selected-none'),
                ),
                ...parents.map(
                  (parent) => _parentOption(
                    context,
                    parent,
                    key: Key('identification-parent-selected-${parent.id}'),
                  ),
                ),
              ],
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: _parentOption(
                    context,
                    null,
                    key: const Key('identification-parent-option-none'),
                  ),
                ),
                ...parents.map(
                  (parent) => DropdownMenuItem<String?>(
                    value: parent.id,
                    child: _parentOption(
                      context,
                      parent,
                      key: Key('identification-parent-option-${parent.id}'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasChildren)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Esta categoria possui subcategorias e não pode ser filha de outra categoria.',
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
              key: const Key('identification-parent-error'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _parentOption(
    BuildContext context,
    AccountabilityIdentification? parent, {
    Key? key,
  }) {
    final theme = Theme.of(context);
    final color = parent?.color ?? theme.colorScheme.onSurfaceVariant;
    final description = parent == null
        ? 'Nenhuma (categoria pai)'
        : '${parent.description}${parent.discontinued ? ' (descontinuada)' : ''}';

    return Row(
      key: key,
      children: [
        Icon(parent?.icon ?? Icons.help_outline, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
