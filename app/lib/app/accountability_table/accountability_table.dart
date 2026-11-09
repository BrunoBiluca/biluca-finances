import 'package:biluca_financas/app/accountability_table/widgets/accountability_table_row.dart';
import 'package:biluca_financas/common/extensions/string_extensions.dart';
import 'package:biluca_financas/common/formatters/formatter.dart';
import 'package:biluca_financas/common/ui/number_field_edit.dart';
import 'package:biluca_financas/common/ui/text_field_edit.dart';
import 'package:biluca_financas/core/accountability/models/accountability_entry.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AccountabilityTable extends StatefulWidget {
  final List<dynamic> entries;
  final void Function(dynamic) onUpdate;
  final void Function(dynamic) onRemove;
  final bool showInsertedAt;
  final IconData removeIcon;
  final String removeTooltip;
  final bool enableInlineEditing;
  final List<AccountabilityIdentification> identifications;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback? onLoadMore;

  const AccountabilityTable({
    super.key,
    required this.entries,
    required this.onUpdate,
    required this.onRemove,
    this.showInsertedAt = false,
    this.removeIcon = Icons.delete,
    this.removeTooltip = "Remover",
    this.enableInlineEditing = false,
    this.identifications = const [],
    this.hasMore = false,
    this.isLoadingMore = false,
    this.onLoadMore,
  });

  @override
  State<AccountabilityTable> createState() => _AccountabilityTableState();
}

class _AccountabilityTableState extends State<AccountabilityTable> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  int? _editingRowIndex;
  String? _draftIdentificationId;
  String? _valueError;
  String createAtMonth = "";

  @override
  void initState() {
    super.initState();
    if (widget.entries.isNotEmpty) {
      createAtMonth = _formatMonth(widget.entries.first.createdAt);
    }
    _scrollController.addListener(_updateVisibleMonth);
  }

  @override
  void didUpdateWidget(covariant AccountabilityTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.entries.isEmpty) {
      createAtMonth = "";
    } else if (oldWidget.entries.isEmpty || oldWidget.entries.first != widget.entries.first) {
      createAtMonth = _formatMonth(widget.entries.first.createdAt);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _valueController.dispose();
    _scrollController
      ..removeListener(_updateVisibleMonth)
      ..dispose();
    super.dispose();
  }

  String _formatMonth(DateTime date) => DateFormat("MMM yyyy", "pt_BR").format(date).capitalize();

  void _updateVisibleMonth() {
    if (!_scrollController.hasClients || widget.entries.isEmpty) return;

    final rowIndex = (_scrollController.position.pixels / 56).truncate();
    if (rowIndex >= widget.entries.length) return;

    final currentMonth = _formatMonth(widget.entries[rowIndex].createdAt);
    if (currentMonth != createAtMonth) {
      setState(() => createAtMonth = currentMonth);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final columns = [
      DataColumn2(label: Text("Criação - $createAtMonth"), size: ColumnSize.S),
      DataColumn2(label: Text("Descrição"), size: ColumnSize.L),
      DataColumn2(label: Text("Valor"), size: ColumnSize.S),
      DataColumn2(label: Text("Identificação"), size: ColumnSize.M),
      DataColumn2(
        label: const Text("Ações"),
        fixedWidth: widget.enableInlineEditing ? 120 : 80,
      ),
    ];

    if (widget.showInsertedAt) {
      columns.insert(
        0,
        const DataColumn2(label: Text("Inserido em"), size: ColumnSize.S),
      );
    }

    final table = DataTable2(
      scrollController: _scrollController,
      minWidth: 900,
      isHorizontalScrollBarVisible: true,
      showBottomBorder: false,
      dividerThickness: 1,
      bottomMargin: 8,
      headingRowHeight: 52,
      dataRowHeight: 56,
      horizontalMargin: 20,
      columnSpacing: 20,
      headingRowDecoration: const BoxDecoration(color: Color(0xFF0A0E17)),
      headingTextStyle: theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
      ),
      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerLow),
      border: TableBorder(
        horizontalInside: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      columns: columns,
      rows: [
        for (var index = 0; index < widget.entries.length; index++) _buildRow(context, widget.entries[index], index),
      ],
    );

    if (widget.onLoadMore == null) {
      return table;
    }

    return Column(
      children: [
        Expanded(child: table),
        if (widget.hasMore)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                key: const Key('load-more-accountability'),
                onPressed: widget.isLoadingMore ? null : widget.onLoadMore,
                child: widget.isLoadingMore
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('(${widget.entries.length}) Carregar mais'),
              ),
            ),
          ),
      ],
    );
  }

  DataRow2 _buildRow(BuildContext context, dynamic entry, int rowIndex) {
    final isEditing = widget.enableInlineEditing && _editingRowIndex == rowIndex;

    return AccountabilityTableRow(
      entry: entry,
      rowIndex: rowIndex,
      showInsertedAt: widget.showInsertedAt,
      enableInlineEditing: widget.enableInlineEditing,
      isEditing: isEditing,
      removeIcon: widget.removeIcon,
      removeTooltip: widget.removeTooltip,
      descriptionController: _descriptionController,
      valueController: _valueController,
      valueError: _valueError,
      draftIdentificationId: _draftIdentificationId,
      identifications: widget.identifications,
      onDescriptionTap: widget.enableInlineEditing
          ? null
          : () => editText(
                context,
                entry.descriptionAlt ?? entry.description,
                (description) => widget.onUpdate(entry..descriptionAlt = description),
              ),
      onValueTap: widget.enableInlineEditing
          ? null
          : () => editNumber(
                context,
                entry.value,
                (value) => widget.onUpdate(entry..value = value),
              ),
      onValueChanged: (_) => setState(() => _valueError = null),
      onIdentificationChanged: (identificationId) {
        setState(() => _draftIdentificationId = identificationId);
      },
      onIdentificationEdit: (identification) => widget.onUpdate(entry..identification = identification),
      onStartEditing: () => _startEditing(entry, rowIndex),
      onSaveEditing: () => _saveEditing(entry),
      onCancelEditing: _cancelEditing,
      onRemove: () => widget.onRemove(entry),
    ).build(context);
  }

  void _startEditing(dynamic entry, int rowIndex) {
    final identificationId =
        entry is AccountabilityEntry ? entry.identificationId ?? entry.identification?.id : entry.identification?.id;
    _descriptionController.text = entry.descriptionAlt ?? entry.description;
    _valueController.text = Formatter.number(entry.value);
    setState(() {
      _editingRowIndex = rowIndex;
      _draftIdentificationId = identificationId;
      _valueError = null;
    });
  }

  void _cancelEditing() {
    setState(_discardDraft);
  }

  void _saveEditing(dynamic entry) {
    final valueText = _valueController.text.trim();
    final normalizedValue = valueText.contains(',') ? valueText.replaceAll('.', '').replaceAll(',', '.') : valueText;
    final value = double.tryParse(normalizedValue);
    if (value == null || !value.isFinite) {
      setState(() => _valueError = 'Informe um valor válido');
      return;
    }

    AccountabilityIdentification? identification;
    for (final item in widget.identifications) {
      if (item.id == _draftIdentificationId) {
        identification = item;
        break;
      }
    }

    entry
      ..descriptionAlt = _descriptionController.text
      ..value = value
      ..identification = identification;
    if (entry is AccountabilityEntry) {
      entry.identificationId = identification?.id;
    }
    setState(_discardDraft);
    widget.onUpdate(entry);
  }

  void _discardDraft() {
    _editingRowIndex = null;
    _draftIdentificationId = null;
    _valueError = null;
  }
}
