import 'dart:io';

import 'package:biluca_financas/app/accountability_import_verification/accountability_import_verification.dart';
import 'package:biluca_financas/app/accountability_new_entry_form/accountability_new_entry_form.dart';
import 'package:biluca_financas/app/accountability_table/accountability_table.dart';
import 'package:biluca_financas/common/formatters/formatter.dart';
import 'package:biluca_financas/common/ui/base_toast.dart';
import 'package:biluca_financas/core/accountability/bloc/accountability_bloc.dart';
import 'package:biluca_financas/core/accountability/bloc/accountability_events.dart';
import 'package:biluca_financas/core/accountability/bloc/accountability_states.dart';
import 'package:biluca_financas/core/accountability/models/accountability_entry_filter.dart';
import 'package:biluca_financas/core/accountability/models/accountability_entry_request.dart';
import 'package:biluca_financas/core/accountability/validators/real_input_formatter.dart';
import 'package:biluca_financas/core/accountability_import/services/accountability_import_service.dart';
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
  final TextEditingController _minValueController = TextEditingController();
  final TextEditingController _maxValueController = TextEditingController();
  final RealInputFormatter _valueFormatter = RealInputFormatter();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _showAdvancedFilters = false;
  bool _isImporting = false;
  String? _importError;
  File? _failedImportFile;
  String? _failedImportName;

  @override
  void dispose() {
    _searchController.dispose();
    _minValueController.dispose();
    _maxValueController.dispose();
    super.dispose();
  }

  AccountabilityEntryFilter get _currentFilter => AccountabilityEntryFilter(
        startDate: _startDate,
        endDate: _endDate,
        minValue: _parseValue(_minValueController.text),
        maxValue: _parseValue(_maxValueController.text),
      );

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountabilityBloc, AccountabilityState>(
      listenWhen: (previous, current) =>
          previous.entryCreationVersion != current.entryCreationVersion,
      listener: (context, state) {
        GetIt.I<FToast>().showToast(
          child: const BaseToast(
            text: 'Registro criado com sucesso',
            type: BaseToastType.success,
          ),
          gravity: ToastGravity.BOTTOM_RIGHT,
          toastDuration: const Duration(seconds: 2),
        );
      },
      child: BlocBuilder<AccountabilityBloc, AccountabilityState>(
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
                  if (state.failureMessage != null) ...[
                    const SizedBox(height: 12),
                    _buildErrorBanner(context, state),
                  ],
                  if (_isImporting) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(
                      key: Key('import-progress'),
                      minHeight: 3,
                    ),
                  ],
                  if (_importError != null) ...[
                    const SizedBox(height: 12),
                    _buildImportErrorBanner(context),
                  ],
                  if (state.resultCount != null &&
                      state.failureMessage == null) ...[
                    const SizedBox(height: 12),
                    _buildResultCount(context, state),
                  ],
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
      ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final searchField = TextField(
                key: const Key('accountability-search'),
                controller: _searchController,
                onChanged: (query) => _search(
                  query: query,
                  identificationId: state.identificationId,
                ),
                decoration: InputDecoration(
                  hintText: 'Pesquisar descrição, categoria ou valor...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    key: const Key('accountability-toggle-filters'),
                    tooltip: 'Filtros de período e valor',
                    icon: Icon(
                      _currentFilter.isEmpty ? Icons.tune : Icons.filter_alt,
                      color: _currentFilter.isEmpty
                          ? null
                          : theme.colorScheme.primary,
                    ),
                    onPressed: () => setState(
                      () => _showAdvancedFilters = !_showAdvancedFilters,
                    ),
                  ),
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
          if (_showAdvancedFilters) ...[
            const SizedBox(height: 16),
            _buildPeriodAndValueFilters(context, state),
          ],
        ],
      ),
    );
  }

  Widget _buildPeriodAndValueFilters(
    BuildContext context,
    AccountabilityState state,
  ) {
    final theme = Theme.of(context);
    final hasFilter = _currentFilter.isNotEmpty;

    return Wrap(
      key: const Key('accountability-advanced-filters'),
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _dateFilterButton(
          context,
          key: const Key('accountability-start-date'),
          label: 'Data inicial',
          date: _startDate,
          onSelected: (date) => _updateDateFilter(
            state,
            startDate: date,
          ),
        ),
        _dateFilterButton(
          context,
          key: const Key('accountability-end-date'),
          label: 'Data final',
          date: _endDate,
          onSelected: (date) => _updateDateFilter(
            state,
            endDate: date,
          ),
        ),
        SizedBox(
          width: 170,
          child: TextField(
            key: const Key('accountability-min-value'),
            controller: _minValueController,
            keyboardType: TextInputType.number,
            inputFormatters: [_valueFormatter],
            onChanged: (_) => _search(identificationId: state.identificationId),
            decoration: _valueFieldDecoration(theme, 'Valor mínimo'),
          ),
        ),
        SizedBox(
          width: 170,
          child: TextField(
            key: const Key('accountability-max-value'),
            controller: _maxValueController,
            keyboardType: TextInputType.number,
            inputFormatters: [_valueFormatter],
            onChanged: (_) => _search(identificationId: state.identificationId),
            decoration: _valueFieldDecoration(theme, 'Valor máximo'),
          ),
        ),
        if (hasFilter)
          TextButton.icon(
            key: const Key('accountability-clear-filter'),
            onPressed: () => _clearPeriodAndValueFilters(state),
            icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
            label: const Text('Limpar filtros'),
          ),
      ],
    );
  }

  InputDecoration _valueFieldDecoration(ThemeData theme, String hint) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      filled: true,
      fillColor: theme.colorScheme.surfaceContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
    );
  }

  Widget _dateFilterButton(
    BuildContext context, {
    required Key key,
    required String label,
    required DateTime? date,
    required ValueChanged<DateTime> onSelected,
  }) {
    return OutlinedButton.icon(
      key: key,
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (picked != null) onSelected(picked);
      },
      icon: const Icon(Icons.calendar_month_outlined, size: 18),
      label: Text(date == null ? label : Formatter.date(date)),
    );
  }

  void _updateDateFilter(
    AccountabilityState state, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    setState(() {
      if (startDate != null) _startDate = startDate;
      if (endDate != null) _endDate = endDate;
    });
    _search(identificationId: state.identificationId);
  }

  void _clearPeriodAndValueFilters(AccountabilityState state) {
    setState(() {
      _startDate = null;
      _endDate = null;
      _minValueController.clear();
      _maxValueController.clear();
    });
    _search(identificationId: state.identificationId);
  }

  double? _parseValue(String text) {
    if (text.trim().isEmpty) return null;
    try {
      final parsed = _valueFormatter.parse(text);
      return parsed.isFinite ? parsed : null;
    } on FormatException {
      return null;
    }
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
    if (state.entries.isEmpty && state.failureMessage != null) {
      return const SizedBox.shrink();
    }

    if (state.entries.isEmpty) {
      if (state.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      final hasFilters = state.searchQuery.isNotEmpty ||
          state.identificationId != null ||
          _currentFilter.isNotEmpty;
      return Center(child: _buildEmptyState(context, state, hasFilters));
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

  Widget _buildEmptyState(
    BuildContext context,
    AccountabilityState state,
    bool hasFilters,
  ) {
    final theme = Theme.of(context);
    return Column(
      key: const Key('accountability-empty-state'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          hasFilters
              ? Icons.filter_alt_off_outlined
              : Icons.receipt_long_outlined,
          size: 40,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 12),
        Text(
          hasFilters
              ? 'Nenhum lançamento corresponde aos filtros'
              : 'Nenhuma entrada registrada',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        if (hasFilters)
          TextButton.icon(
            key: const Key('accountability-empty-clear'),
            onPressed: () => _clearAllFilters(),
            icon: const Icon(Icons.filter_alt_off_outlined),
            label: const Text('Limpar filtros'),
          )
        else
          FilledButton.icon(
            key: const Key('accountability-empty-create'),
            onPressed: () => newEntry(context),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Nova entrada'),
          ),
      ],
    );
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _minValueController.clear();
      _maxValueController.clear();
      _startDate = null;
      _endDate = null;
      _showAdvancedFilters = false;
    });
    _search(identificationId: null);
  }

  Widget _buildErrorBanner(BuildContext context, AccountabilityState state) {
    final theme = Theme.of(context);
    return Container(
      key: const Key('accountability-error-banner'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              state.failureMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
          TextButton(
            key: const Key('accountability-retry'),
            onPressed: () => context
                .read<AccountabilityBloc>()
                .add(RetryAccountability()),
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildImportErrorBanner(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: const Key('import-error-banner'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _importError!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
          TextButton(
            key: const Key('import-retry'),
            onPressed: _retryImport,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCount(
    BuildContext context,
    AccountabilityState state,
  ) {
    final theme = Theme.of(context);
    final count = state.resultCount ?? 0;
    return Text(
      count == 1 ? '1 lançamento encontrado' : '$count lançamentos encontrados',
      key: const Key('accountability-result-count'),
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  void _search({String? query, required String? identificationId}) {
    context.read<AccountabilityBloc>().add(
          SearchAccountabilityEntries(
            query: query ?? _searchController.text,
            identificationId: identificationId,
            filter: _currentFilter,
          ),
        );
  }

  Future<void> importEntries(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null) return;
    if (!mounted) return;

    await _importFile(
      File(result.files.single.path!),
      result.files.single.name,
    );
  }

  Future<void> _importFile(File file, String fileName) async {
    final importService = GetIt.I<AccountabilityImportService>();
    setState(() {
      _isImporting = true;
      _importError = null;
    });

    try {
      await importService.import(file);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isImporting = false;
        _importError = 'Não foi possível importar o arquivo. Tente novamente.';
        _failedImportFile = file;
        _failedImportName = fileName;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _isImporting = false;
      _failedImportFile = null;
      _failedImportName = null;
    });

    GetIt.I<FToast>().showToast(
      child: const BaseToast(
        text: 'Arquivo importado',
        type: BaseToastType.information,
      ),
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 2),
    );

    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (context) => BlocProvider(
        create: (_) =>
            GetIt.I<AccountabilityBloc>()..add(FetchAccountabilityEntries()),
        child: AccountabilityImportVerification(
          service: importService,
          sourceFileName: fileName,
        ),
      ),
    );
  }

  void _retryImport() {
    final file = _failedImportFile;
    final name = _failedImportName;
    if (file == null || name == null) return;
    _importFile(file, name);
  }

  Future<void> newEntry(BuildContext context) async {
    final entryRequest = await showDialog<AccountabilityEntryRequest>(
      context: context,
      builder: (context) => const AccountabilityEntryForm(),
    );

    if (entryRequest == null) return;
    if (!context.mounted) return;

    context
        .read<AccountabilityBloc>()
        .add(AddAccountabilityEntry(entryRequest));
  }
}
