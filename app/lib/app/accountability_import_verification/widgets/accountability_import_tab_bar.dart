import 'package:flutter/material.dart';

class AccountabilityImportTabBar extends StatelessWidget {
  final int newEntriesCount;
  final int duplicatedEntriesCount;

  const AccountabilityImportTabBar({
    super.key,
    required this.newEntriesCount,
    required this.duplicatedEntriesCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TabBar(
          key: const Key('import-verification-tabs'),
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            _tab(
              context,
              label: 'Novas Entradas',
              count: newEntriesCount,
              accent: theme.colorScheme.primary,
              countKey: const Key('import-tab-count-new'),
            ),
            _tab(
              context,
              label: 'Registros Duplicados',
              count: duplicatedEntriesCount,
              accent: theme.colorScheme.secondary,
              countKey: const Key('import-tab-count-duplicates'),
            ),
            const Tab(text: 'Regras Aplicadas'),
          ],
        ),
      ),
    );
  }

  Tab _tab(
    BuildContext context, {
    required String label,
    required int count,
    required Color accent,
    required Key countKey,
  }) {
    final theme = Theme.of(context);
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$count',
              key: countKey,
              style: theme.textTheme.labelMedium?.copyWith(
                color: accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
