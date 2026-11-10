import 'package:biluca_financas/core/accountability/models/identification_consolidation.dart';
import 'package:flutter/material.dart';

class IdentificationConsolidationCards extends StatelessWidget {
  final IdentificationConsolidation consolidation;

  const IdentificationConsolidationCards({
    super.key,
    required this.consolidation,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final width = constraints.maxWidth;
        final columns = width >= 900 ? 4 : (width >= 520 ? 2 : 1);
        final cardWidth =
            columns == 1 ? width : (width - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            _ConsolidationCard(
              key: const Key('identification-consolidation-total'),
              width: cardWidth,
              label: 'Total de categorias',
              valueKey: const Key('identification-total-count'),
              value: consolidation.total,
              hint: 'Todas as categorias',
              valueColor: Theme.of(context).colorScheme.onSurface,
            ),
            _ConsolidationCard(
              key: const Key('identification-consolidation-parents'),
              width: cardWidth,
              label: 'Categorias pai',
              valueKey: const Key('identification-parent-count'),
              value: consolidation.parents,
              hint: 'Nível raiz',
              valueColor: Theme.of(context).colorScheme.primary,
            ),
            _ConsolidationCard(
              key: const Key('identification-consolidation-subcategories'),
              width: cardWidth,
              label: 'Subcategorias',
              valueKey: const Key('identification-subcategory-count'),
              value: consolidation.subcategories,
              hint: '1º nível',
              valueColor: Theme.of(context).colorScheme.secondary,
            ),
            _ConsolidationCard(
              key: const Key('identification-consolidation-discontinued'),
              width: cardWidth,
              label: 'Categorias descontinuadas',
              valueKey: const Key('identification-discontinued-count'),
              value: consolidation.discontinued,
              hint: 'Histórico preservado',
              valueColor: Theme.of(context).colorScheme.tertiary,
            ),
          ],
        );
      },
    );
  }
}

class _ConsolidationCard extends StatelessWidget {
  final double width;
  final String label;
  final Key valueKey;
  final int value;
  final String hint;
  final Color valueColor;

  const _ConsolidationCard({
    super.key,
    required this.width,
    required this.label,
    required this.valueKey,
    required this.value,
    required this.hint,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$value',
                key: valueKey,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
