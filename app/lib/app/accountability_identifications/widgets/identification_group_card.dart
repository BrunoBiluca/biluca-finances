import 'package:biluca_financas/common/extensions/color_extensions.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:flutter/material.dart';

const Color _blockBorderColor = Color(0xFF272D36);
const double _blockRadius = 6;

class IdentificationGroupCard extends StatelessWidget {
  final AccountabilityIdentification category;
  final List<AccountabilityIdentification> children;
  final String? parentName;
  final VoidCallback onEdit;
  final ValueChanged<AccountabilityIdentification> onEditChild;
  final VoidCallback? onAddSubcategory;

  const IdentificationGroupCard({
    super.key,
    required this.category,
    required this.children,
    required this.onEdit,
    required this.onEditChild,
    this.parentName,
    this.onAddSubcategory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDiscontinued = category.discontinued;

    return Opacity(
      key: Key('identification-opacity-${category.id}'),
      opacity: isDiscontinued ? (category.isRoot ? 0.9 : 0.8) : 1.0,
      child: Container(
        key: Key('identification-group-${category.id}'),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(_blockRadius),
          border: Border.all(color: _blockBorderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, isDiscontinued),
            if (children.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                height: 1,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 10),
              ...children.map(
                (child) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildChild(context, child),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDiscontinued) {
    final theme = Theme.of(context);
    final accent =
        isDiscontinued ? theme.colorScheme.onSurfaceVariant : category.color;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent.withValues(alpha: 0.35)),
          ),
          child: Icon(category.icon, color: accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    category.description,
                    key: Key('identification-name-${category.id}'),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDiscontinued
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.onSurface,
                      decoration:
                          isDiscontinued ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  _Badge(
                    label: category.isRoot ? 'Categoria Pai' : 'Subcategoria',
                    icon: category.isRoot
                        ? Icons.folder_open
                        : Icons.subdirectory_arrow_right,
                    color: category.isRoot
                        ? theme.colorScheme.primary
                        : Colors.grey.shade500,
                  ),
                  _StatusBadge(
                    key: Key('identification-status-${category.id}'),
                    discontinued: isDiscontinued,
                  ),
                ],
              ),
              if (parentName != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Subcategoria de $parentName',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          key: Key('edit-identification-${category.id}'),
          tooltip: 'Editar categoria',
          onPressed: onEdit,
          icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
        ),
        if (onAddSubcategory != null)
          IconButton(
            key: Key('add-subcategory-${category.id}'),
            tooltip: 'Adicionar subcategoria',
            onPressed: onAddSubcategory,
            icon: Icon(
              Icons.add_circle_outline,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  Widget _buildChild(BuildContext context, AccountabilityIdentification child) {
    final theme = Theme.of(context);
    final isDiscontinued = child.discontinued;
    final accent =
        isDiscontinued ? theme.colorScheme.onSurfaceVariant : child.color;

    return Opacity(
      key: Key('identification-opacity-${child.id}'),
      opacity: isDiscontinued ? 0.8 : 1.0,
      child: Container(
        key: Key('identification-item-${child.id}'),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            Colors.white.withValues(alpha: 0.04),
            theme.colorScheme.surfaceContainerLow,
          ),
          borderRadius: BorderRadius.circular(_blockRadius),
          border: Border.all(color: _blockBorderColor),
        ),
        child: Row(
          children: [
            Text(
              '└─',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(child.icon, size: 17, color: accent),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        child.description,
                        key: Key('identification-name-${child.id}'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDiscontinued
                              ? theme.colorScheme.onSurfaceVariant
                              : theme.colorScheme.onSurface,
                          decoration: isDiscontinued
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      _Badge(
                        label: 'Subcategoria',
                        icon: Icons.subdirectory_arrow_right,
                        color: Colors.grey.shade500,
                      ),
                      _StatusBadge(
                        key: Key('identification-status-${child.id}'),
                        discontinued: isDiscontinued,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              key: Key('edit-identification-${child.id}'),
              tooltip: 'Editar subcategoria',
              onPressed: () => onEditChild(child),
              icon: Icon(
                Icons.edit_outlined,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _Badge({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool discontinued;

  const _StatusBadge({super.key, required this.discontinued});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        discontinued ? theme.colorScheme.tertiary : theme.colorScheme.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            discontinued ? Icons.archive_outlined : Icons.check_circle_outline,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              discontinued ? 'Descontinuada' : 'Ativa',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
