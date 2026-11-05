import 'dart:io';

import 'package:biluca_financas/app/accountability_import_verification/accountability_import_verification.dart';
import 'package:biluca_financas/app/accountability_new_entry_form/accountability_new_entry_form.dart';
import 'package:biluca_financas/app/accountability_table/accountability_table.dart';
import 'package:biluca_financas/common/ui/base_toast.dart';
import 'package:biluca_financas/core/accountability/bloc/accountability_bloc.dart';
import 'package:biluca_financas/core/accountability/bloc/accountability_events.dart';
import 'package:biluca_financas/core/accountability/bloc/accountability_states.dart';
import 'package:biluca_financas/core/accountability/models/accountability_entry_request.dart';
import 'package:biluca_financas/core/accountability_import/services/accountability_import_service.dart';
import 'package:biluca_financas/integrations/embedded_server/embedded_predict_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';

class AccountabilityPage extends StatelessWidget {
  const AccountabilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<AccountabilityBloc>()
        ..add(const SearchAccountabilityEntries(
            query: '', identificationId: null)),
      child: const _AccountabilityPageContent(),
    );
  }
}

class _AccountabilityPageContent extends StatefulWidget {
  const _AccountabilityPageContent();

  @override
  State<_AccountabilityPageContent> createState() =>
      _AccountabilityPageContentState();
}

class _AccountabilityPageContentState
    extends State<_AccountabilityPageContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountabilityBloc, AccountabilityState>(
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final entries = _buildEntries(context, state);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildSearchAndFilters(context, state),
                const SizedBox(height: 20),
                if (constraints.hasBoundedHeight)
                  Expanded(child: entries)
                else
                  SizedBox(height: 560, child: entries),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final actions = Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          children: [
            OutlinedButton.icon(
              key: const Key('import-accountability'),
              onPressed: () => importEntries(context),
              icon: const Icon(Icons.file_upload_outlined),
              label: const Text('Importar'),
            ),
            FilledButton.icon(
              key: const Key('new-accountability-entry'),
              onPressed: () => newEntry(context),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Nova entrada'),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );

        if (constraints.maxWidth < 680) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _pageTitle(theme),
              const SizedBox(height: 16),
              actions,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: _pageTitle(theme)),
            actions,
          ],
        );
      },
    );
  }

  Widget _pageTitle(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contabilidade',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.primary,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text('Prestação de Contas', style: theme.textTheme.displaySmall),
      ],
    );
  }

  Widget _buildSearchAndFilters(
      BuildContext context, AccountabilityState state) {
    final theme = Theme.of(context);
    final categories = Wrap(
      key: const Key('accountability-category-filters'),
      spacing: 8,
      runSpacing: 4,
      children: [
        _categoryChip(
          context,
          label: 'Todos',
          selected: state.identificationId == null,
          onSelected: () => _search(identificationId: null),
        ),
        for (final identification in state.identifications)
          _categoryChip(
            context,
            label: identification.description,
            selected: state.identificationId == identification.id,
            onSelected: () => _search(identificationId: identification.id),
          ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final searchField = TextField(
            key: const Key('accountability-search'),
            controller: _searchController,
            onChanged: (query) =>
                _search(query: query, identificationId: state.identificationId),
            decoration: InputDecoration(
              hintText: 'Pesquisar descrição, categoria ou valor...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainer,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          );

          if (constraints.maxWidth < 760) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                searchField,
                const SizedBox(height: 12),
                categories,
              ],
            );
          }

          return Row(
            children: [
              Expanded(flex: 4, child: searchField),
              const SizedBox(width: 20),
              Expanded(flex: 5, child: categories),
            ],
          );
        },
      ),
    );
  }

  Widget _categoryChip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    final theme = Theme.of(context);
    return FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onSelected(),
      selectedColor: theme.colorScheme.primaryContainer,
      backgroundColor: theme.colorScheme.surfaceContainer,
      labelStyle: theme.textTheme.bodySmall?.copyWith(
        color: selected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurfaceVariant,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildEntries(BuildContext context, AccountabilityState state) {
    if (state.entries.isEmpty) {
      if (state.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      final hasFilters =
          state.searchQuery.isNotEmpty || state.identificationId != null;
      return Center(
        child: Text(
          hasFilters
              ? 'Nenhum lançamento corresponde aos filtros'
              : 'Nenhuma entrada registrada',
          key: const Key('accountability-empty-state'),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: AccountabilityTable(
        entries: state.entries,
        onUpdate: (entry) => context
            .read<AccountabilityBloc>()
            .add(UpdateAccountabilityEntry(entry)),
        onRemove: (entry) => context
            .read<AccountabilityBloc>()
            .add(DeleteAccountabilityEntry(entry)),
        enableInlineEditing: true,
        identifications: state.identifications,
        hasMore: state.hasMore,
        isLoadingMore: state.isLoading,
        onLoadMore: () => context
            .read<AccountabilityBloc>()
            .add(LoadMoreAccountabilityEntries()),
      ),
    );
  }

  void _search({String? query, required String? identificationId}) {
    context.read<AccountabilityBloc>().add(
          SearchAccountabilityEntries(
            query: query ?? _searchController.text,
            identificationId: identificationId,
          ),
        );
  }

  Future<void> importEntries(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null) return;

    final file = File(result.files.single.path!);
    final importService = GetIt.I<AccountabilityImportService>();
    await importService.import(file);
    GetIt.I<FToast>().showToast(
      child: const BaseToast(text: 'Arquivo importado'),
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 2),
    );

    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (context) => BlocProvider(
        create: (_) =>
            GetIt.I<AccountabilityBloc>()..add(FetchAccountabilityEntries()),
        child: AccountabilityImportVerification(service: importService),
      ),
    );
  }

  Future<void> newEntry(BuildContext context) async {
    var entryRequest = await showDialog<AccountabilityEntryRequest>(
      context: context,
      builder: (context) => const AccountabilityEntryForm(),
    );

    if (entryRequest == null) return;

    if (entryRequest.identification == null) {
      final entries = await GetIt.I<EmbeddedPredictService>()
          .predict(entries: [entryRequest]);
      entryRequest = entries[0];
    }

    if (!context.mounted) return;
    context
        .read<AccountabilityBloc>()
        .add(AddAccountabilityEntry(entryRequest));
  }
}
