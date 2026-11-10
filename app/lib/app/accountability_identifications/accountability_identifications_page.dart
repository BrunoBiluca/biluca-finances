import 'package:biluca_financas/app/accountability_identifications/widgets/identification_consolidation_cards.dart';
import 'package:biluca_financas/app/accountability_identifications/widgets/identification_edit_modal.dart';
import 'package:biluca_financas/app/accountability_identifications/widgets/identification_group_card.dart';
import 'package:biluca_financas/app/accountability_identifications/widgets/identification_status_tabs.dart';
import 'package:biluca_financas/core/accountability/bloc/identification_categories_bloc.dart';
import 'package:biluca_financas/core/accountability/bloc/identification_categories_events.dart';
import 'package:biluca_financas/core/accountability/bloc/identification_categories_states.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification_type.dart';
import 'package:biluca_financas/core/accountability/models/identification_consolidation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class AccountabilityIdentificationsPage extends StatelessWidget {
  const AccountabilityIdentificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<IdentificationCategoriesBloc>()..add(const LoadIdentificationCategories()),
      child: const _AccountabilityIdentificationsContent(),
    );
  }
}

class _AccountabilityIdentificationsContent extends StatefulWidget {
  const _AccountabilityIdentificationsContent();

  @override
  State<_AccountabilityIdentificationsContent> createState() => _AccountabilityIdentificationsContentState();
}

class _AccountabilityIdentificationsContentState extends State<_AccountabilityIdentificationsContent> {
  IdentificationStatusFilter _filter = IdentificationStatusFilter.all;
  AccountabilityIdentificationType? _typeFilter;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IdentificationCategoriesBloc, IdentificationCategoriesState>(
      builder: (context, state) {
        final consolidation = IdentificationConsolidation.fromIdentifications(state.identifications);
        final typeFiltered = state.identifications
            .where(
              (item) => _typeFilter == null || item.type == _typeFilter,
            )
            .toList();
        final activeCount = typeFiltered.where((item) => !item.discontinued).length;
        final discontinuedCount = typeFiltered.where((item) => item.discontinued).length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            IdentificationConsolidationCards(consolidation: consolidation),
            const SizedBox(height: 20),
            IdentificationStatusTabs(
              selected: _filter,
              total: typeFiltered.length,
              active: activeCount,
              discontinued: discontinuedCount,
              typeFilter: _typeFilter,
              onChanged: (filter) => setState(() => _filter = filter),
              onTypeChanged: (type) => setState(() => _typeFilter = type),
            ),
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: LinearProgressIndicator(minHeight: 2),
              ),
            const SizedBox(height: 16),
            _buildList(context, state),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configurações',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.primary,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Identificações & Categorias',
          key: const Key('identification-page-title'),
          style: theme.textTheme.displaySmall,
        ),
        const SizedBox(height: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Text(
            'Hierarquia de um nível entre categorias pai e subcategorias, com criação, edição e descontinuação das identificações usadas nos lançamentos.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );

    final action = FilledButton.icon(
      key: const Key('new-identification-category'),
      onPressed: () => _openCreate(context),
      icon: const Icon(Icons.add),
      label: const Text('Nova identificação'),
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              title,
              const SizedBox(height: 16),
              Align(alignment: Alignment.centerLeft, child: action),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: title),
            const SizedBox(width: 20),
            action,
          ],
        );
      },
    );
  }

  Widget _buildList(
    BuildContext context,
    IdentificationCategoriesState state,
  ) {
    final filtered = state.identifications
        .where(
          (item) =>
              (_typeFilter == null || item.type == _typeFilter) &&
              switch (_filter) {
                IdentificationStatusFilter.all => true,
                IdentificationStatusFilter.active => !item.discontinued,
                IdentificationStatusFilter.discontinued => item.discontinued,
              },
        )
        .toList();

    if (filtered.isEmpty) {
      return Container(
        key: const Key('identification-empty-state'),
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.category_outlined,
              size: 32,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              'Nenhuma categoria para os filtros atuais.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    final visibleIds = filtered.map((item) => item.id).toSet();
    final byId = {
      for (final item in state.identifications) item.id: item,
    };
    final roots = filtered
        .where(
          (item) => item.parentId == null || !visibleIds.contains(item.parentId),
        )
        .toList()
      ..sort(_compareCategories);

    return Column(
      children: [
        for (var index = 0; index < roots.length; index++) ...[
          if (index > 0) const SizedBox(height: 12),
          _buildGroup(context, roots[index], filtered, byId),
        ],
      ],
    );
  }

  Widget _buildGroup(
    BuildContext context,
    AccountabilityIdentification category,
    List<AccountabilityIdentification> filtered,
    Map<String, AccountabilityIdentification> byId,
  ) {
    final children = filtered.where((item) => item.parentId == category.id).toList()..sort(_compareCategories);
    final parent = category.parentId == null ? null : byId[category.parentId!];

    return IdentificationGroupCard(
      category: category,
      children: children,
      parentName: parent?.description,
      onEdit: () => _openEdit(context, category),
      onEditChild: (child) => _openEdit(context, child),
      onAddSubcategory:
          category.isRoot && !category.discontinued ? () => _openCreate(context, initialParentId: category.id) : null,
    );
  }

  int _compareCategories(
    AccountabilityIdentification first,
    AccountabilityIdentification second,
  ) {
    if (first.discontinued != second.discontinued) {
      return first.discontinued ? 1 : -1;
    }
    return first.description.toLowerCase().compareTo(second.description.toLowerCase());
  }

  void _openCreate(BuildContext context, {String? initialParentId}) {
    final bloc = context.read<IdentificationCategoriesBloc>();
    showDialog<void>(
      context: context,
      builder: (context) => IdentificationEditModal(
        allIdentifications: bloc.state.identifications,
        initialParentId: initialParentId,
        onSave: (identification) => bloc.add(
          CreateIdentificationCategory(identification),
        ),
      ),
    );
  }

  void _openEdit(
    BuildContext context,
    AccountabilityIdentification identification,
  ) {
    final bloc = context.read<IdentificationCategoriesBloc>();
    showDialog<void>(
      context: context,
      builder: (context) => IdentificationEditModal(
        allIdentifications: bloc.state.identifications,
        identification: identification,
        onSave: (updated) => bloc.add(UpdateIdentificationCategory(updated)),
        onDelete: (identificationId) => bloc.add(
          DeleteIdentificationCategory(identificationId),
        ),
      ),
    );
  }
}
