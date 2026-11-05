import 'package:biluca_financas/common/extensions/string_extensions.dart';
import 'package:biluca_financas/common/formatters/formatter.dart';
import 'package:biluca_financas/app/accountability_table/widgets/accountability_identification_label.dart';
import 'package:biluca_financas/common/ui/real_currency.dart';
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

    var dateFormat = DateFormat("MMM yyyy", "pt_BR");
    if (widget.entries.isNotEmpty) {
      createAtMonth =
          dateFormat.format(widget.entries[0].createdAt).capitalize();
    }

    _scrollController.addListener(_updateVisibleMonth);
  }

  @override
  void didUpdateWidget(covariant AccountabilityTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.entries.isEmpty) {
      createAtMonth = "";
    } else if (oldWidget.entries.isEmpty ||
        oldWidget.entries.first != widget.entries.first) {
      createAtMonth = DateFormat("MMM yyyy", "pt_BR")
          .format(widget.entries.first.createdAt)
          .capitalize();
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

  void _updateVisibleMonth() {
    if (!_scrollController.hasClients || widget.entries.isEmpty) return;

    final rowIndex = (_scrollController.position.pixels / 56).truncate();
    if (rowIndex >= widget.entries.length) return;

    final dateFormat = DateFormat("MMM yyyy", "pt_BR");
    final currentMonth =
        dateFormat.format(widget.entries[rowIndex].createdAt).capitalize();
    if (currentMonth != createAtMonth) {
      setState(() => createAtMonth = currentMonth);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var columns = [
      DataColumn2(label: Text("Criação - $createAtMonth"), size: ColumnSize.S),
      DataColumn2(label: Text("Descrição"), size: ColumnSize.L),
      DataColumn2(label: Text("Valor"), size: ColumnSize.S),
      DataColumn2(label: Text("Identificação"), size: ColumnSize.M),
      DataColumn2(
          label: Text("Ações"),
          fixedWidth: widget.enableInlineEditing ? 120 : 80),
    ];

    if (widget.showInsertedAt) {
      columns.insert(
          0, DataColumn2(label: Text("Inserido em"), size: ColumnSize.S));
    }

    final table = DataTable2(
      scrollController: _scrollController,
      minWidth: 900,
      isHorizontalScrollBarVisible: true,
      showBottomBorder: false,
      dividerThickness: 1,
      bottomMargin: 8,
      headingRowHeight: 52,
      dataRowHeight: _editingRowIndex == null
          ? 56
          : _valueError == null
              ? 72
              : 88,
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
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35)),
      ),
      columns: columns,
      rows: [
        for (var index = 0; index < widget.entries.length; index++)
          _tableRow(context, widget.entries[index], index),
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

  DataRow2 _tableRow(BuildContext context, dynamic entry, int rowIndex) {
    List<DataCell> optionalCells = [];
    final isEditing =
        widget.enableInlineEditing && _editingRowIndex == rowIndex;

    if (widget.showInsertedAt) {
      optionalCells.add(DataCell(
        Text(
          Formatter.date(entry.insertedAt),
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ));
    }

    return DataRow2(
      color: WidgetStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(WidgetState.hovered)) {
            return Theme.of(context).colorScheme.surfaceContainerHigh;
          }
          return rowIndex.isOdd ? const Color(0xFF0A0E17) : null;
        },
      ),
      cells: optionalCells +
          [
            DataCell(
              Text(
                Formatter.date(entry.createdAt),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
            DataCell(
              isEditing
                  ? TextField(
                      key: Key('edit-description-$rowIndex'),
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        hintText: 'Descrição',
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    )
                  : Text(
                      entry.descriptionAlt ?? entry.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
              onTap: !widget.enableInlineEditing && !isEditing
                  ? () {
                      editText(
                        context,
                        entry.descriptionAlt ?? entry.description,
                        (updatedText) => widget
                            .onUpdate(entry..descriptionAlt = updatedText),
                      );
                    }
                  : null,
            ),
            DataCell(
              isEditing
                  ? TextField(
                      key: Key('edit-value-$rowIndex'),
                      controller: _valueController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: 'Valor',
                        isDense: true,
                        errorText: _valueError,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                      onChanged: (_) {
                        if (_valueError != null) {
                          setState(() => _valueError = null);
                        }
                      },
                    )
                  : RealCurrency(number: entry.value),
              onTap: !widget.enableInlineEditing && !isEditing
                  ? () => editNumber(
                        context,
                        entry.value,
                        (updatedNumber) =>
                            widget.onUpdate(entry..value = updatedNumber),
                      )
                  : null,
            ),
            DataCell(
              Center(
                child: Padding(
                  padding: EdgeInsets.all(isEditing ? 4 : 8),
                  child: isEditing
                      ? _identificationDropdown(rowIndex)
                      : AccountabilityIdentificationLabel(
                          identification: entry.identification,
                          onEdit: (id) =>
                              widget.onUpdate(entry..identification = id),
                        ),
                ),
              ),
            ),
            DataCell(
              widget.enableInlineEditing
                  ? _inlineActions(context, entry, rowIndex, isEditing)
                  : Semantics(
                      button: true,
                      label: widget.removeTooltip,
                      child: IconButton(
                        key: Key('remove-accountability-$rowIndex'),
                        onPressed: () => widget.onRemove(entry),
                        icon: Icon(
                          widget.removeIcon,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ),
            ),
          ],
    );
  }

  Widget _inlineActions(
    BuildContext context,
    dynamic entry,
    int rowIndex,
    bool isEditing,
  ) {
    if (isEditing) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            button: true,
            label: 'Salvar edição',
            child: IconButton(
              key: Key('save-accountability-edit-$rowIndex'),
              onPressed: () => _saveEditing(entry),
              icon: const Icon(Icons.check),
            ),
          ),
          Semantics(
            button: true,
            label: 'Cancelar edição',
            child: IconButton(
              key: Key('cancel-accountability-edit-$rowIndex'),
              onPressed: _cancelEditing,
              icon: const Icon(Icons.close),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          label: 'Editar lançamento',
          child: IconButton(
            key: Key('edit-accountability-$rowIndex'),
            onPressed: () => _startEditing(entry, rowIndex),
            icon: const Icon(Icons.edit_outlined),
          ),
        ),
        Semantics(
          button: true,
          label: widget.removeTooltip,
          child: IconButton(
            key: Key('remove-accountability-$rowIndex'),
            onPressed: () => widget.onRemove(entry),
            icon: Icon(
              widget.removeIcon,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _identificationDropdown(int rowIndex) {
    final identificationIds =
        widget.identifications.map((item) => item.id).toSet();
    final value = identificationIds.contains(_draftIdentificationId)
        ? _draftIdentificationId
        : null;

    return DropdownButton<String?>(
      key: Key('edit-identification-$rowIndex'),
      value: value,
      isExpanded: true,
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('Não identificado'),
        ),
        ...widget.identifications.map(
          (identification) => DropdownMenuItem<String?>(
            value: identification.id,
            child: Text(identification.description,
                overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: (identificationId) {
        setState(() => _draftIdentificationId = identificationId);
      },
    );
  }

  void _startEditing(dynamic entry, int rowIndex) {
    final identificationId = entry is AccountabilityEntry
        ? entry.identificationId ?? entry.identification?.id
        : entry.identification?.id;
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
    final normalizedValue = valueText.contains(',')
        ? valueText.replaceAll('.', '').replaceAll(',', '.')
        : valueText;
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
