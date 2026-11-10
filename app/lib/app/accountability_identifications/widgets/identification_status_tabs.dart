import 'package:biluca_financas/core/accountability/models/accountability_identification_type.dart';
import 'package:flutter/material.dart';

enum IdentificationStatusFilter { all, active, discontinued }

class IdentificationStatusTabs extends StatelessWidget {
  final IdentificationStatusFilter selected;
  final int total;
  final int active;
  final int discontinued;
  final ValueChanged<IdentificationStatusFilter> onChanged;
  final AccountabilityIdentificationType? typeFilter;
  final ValueChanged<AccountabilityIdentificationType?> onTypeChanged;

  const IdentificationStatusTabs({
    super.key,
    required this.selected,
    required this.total,
    required this.active,
    required this.discontinued,
    required this.onChanged,
    required this.typeFilter,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final statusTabs = Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        _Tab(
          key: const Key('identification-tab-all'),
          label: 'Todas as categorias',
          count: total,
          selected: selected == IdentificationStatusFilter.all,
          onTap: () => onChanged(IdentificationStatusFilter.all),
        ),
        _Tab(
          key: const Key('identification-tab-active'),
          label: 'Categorias ativas',
          count: active,
          selected: selected == IdentificationStatusFilter.active,
          onTap: () => onChanged(IdentificationStatusFilter.active),
        ),
        _Tab(
          key: const Key('identification-tab-discontinued'),
          label: 'Categorias descontinuadas',
          count: discontinued,
          selected: selected == IdentificationStatusFilter.discontinued,
          onTap: () => onChanged(IdentificationStatusFilter.discontinued),
        ),
      ],
    );

    final typeFilterWidget = IdentificationTypeFilter(
      selected: typeFilter,
      onChanged: onTypeChanged,
    );

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 980) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                statusTabs,
                const SizedBox(height: 8),
                typeFilterWidget,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: statusTabs),
              const SizedBox(width: 16),
              typeFilterWidget,
            ],
          );
        },
      ),
    );
  }
}

class IdentificationTypeFilter extends StatelessWidget {
  final AccountabilityIdentificationType? selected;
  final ValueChanged<AccountabilityIdentificationType?> onChanged;

  const IdentificationTypeFilter({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Tipo:',
          style: theme.textTheme.bodyMedium
        ),
        _TypePill(
          key: const Key('identification-type-filter-all'),
          label: 'Todos',
          selected: selected == null,
          onTap: () => onChanged(null),
        ),
        _TypePill(
          key: const Key('identification-type-filter-income'),
          label: 'Receita',
          selected: selected == AccountabilityIdentificationType.income,
          onTap: () => onChanged(AccountabilityIdentificationType.income),
        ),
        _TypePill(
          key: const Key('identification-type-filter-expense'),
          label: 'Despesa',
          selected: selected == AccountabilityIdentificationType.expense,
          onTap: () => onChanged(AccountabilityIdentificationType.expense),
        ),
        _TypePill(
          key: const Key('identification-type-filter-investment'),
          label: 'Investimento',
          selected: selected == AccountabilityIdentificationType.investment,
          onTap: () => onChanged(AccountabilityIdentificationType.investment),
        ),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _Tab({
    super.key,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.surfaceContainerHigh
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$label ($count)',
          style: theme.textTheme.labelMedium?.copyWith(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.surfaceContainerHigh
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
