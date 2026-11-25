import 'dart:async';

import 'package:biluca_financas/app/accountability_table/widgets/accountability_identification_selector.dart';
import 'package:biluca_financas/core/accountability/models/accountability_entry_request.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:biluca_financas/core/accountability/services/accountability_repo.dart';
import 'package:biluca_financas/core/accountability/validators/real_input_formatter.dart';
import 'package:biluca_financas/core/accountability_identification_prediction/service/accountability_identification_prediction_service.dart';
import 'package:biluca_financas/common/ui/base_dialog.dart';
import 'package:biluca_financas/common/ui/forms/data_picker_field.dart';
import 'package:biluca_financas/common/ui/forms/primary_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AccountabilityEntryForm extends StatefulWidget {
  static const Duration predictionDelay = Duration(milliseconds: 600);

  const AccountabilityEntryForm({super.key});

  @override
  State<AccountabilityEntryForm> createState() =>
      _AccountabilityEntryFormState();
}

class _AccountabilityEntryFormState extends State<AccountabilityEntryForm> {
  final descriptionCtrl = TextEditingController();
  final valueCtrl = TextEditingController();
  final inputFormatter = RealInputFormatter();
  DateTime createdAt = DateTime.now();
  String? descriptionError;
  String? valueError;
  String? dateError;
  String? _predictedSignature;
  AccountabilityIdentification? _identification;
  bool _identificationChosenManually = false;
  bool _isPredicting = false;
  Timer? _predictionDebounce;

  @override
  void dispose() {
    _predictionDebounce?.cancel();
    descriptionCtrl.dispose();
    valueCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: "Nova entrada",
      content: SizedBox(
        height: 380,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            PrimaryTextField(
              labelText: 'Descrição',
              autofocus: true,
              controller: descriptionCtrl,
              externalErrorText: descriptionError,
              onChanged: (value) {
                if (value.trim().isNotEmpty && descriptionError != null) {
                  setState(() => descriptionError = null);
                }
                _schedulePrediction();
              },
            ),
            const SizedBox(height: 20),
            PrimaryTextField(
              labelText: 'Valor',
              controller: valueCtrl,
              keyboardType: TextInputType.number,
              externalErrorText: valueError,
              formatters: [inputFormatter],
              onChanged: (value) {
                if (_parseValue(value) != null && valueError != null) {
                  setState(() => valueError = null);
                }
                _schedulePrediction();
              },
            ),
            const SizedBox(height: 20),
            DatePickerField(
              current: createdAt,
              onSelected: (d) => setState(
                () {
                  if (d == null) return;
                  createdAt = d;
                  dateError = null;
                },
              ),
            ),
            const SizedBox(height: 12),
            _buildIdentificationRow(context),
            if (dateError != null)
              Text(
                dateError!,
                key: const Key('entry-date-error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: save,
          child: const Text("Salvar"),
        )
      ],
    );
  }

  Widget _buildIdentificationRow(BuildContext context) {
    final theme = Theme.of(context);
    final identification = _identification;
    final color = identification?.color ?? theme.colorScheme.onSurfaceVariant;

    final Widget label;
    if (_isPredicting) {
      label = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              key: const Key('identification-prediction-progress'),
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Prevendo identificação...',
            style: theme.textTheme.labelMedium,
          ),
        ],
      );
    } else {
      label = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            identification?.icon ?? Icons.help_outline,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              identification?.description ?? 'Não identificado',
              key: identification == null
                  ? const Key('entry-no-identification')
                  : const Key('entry-predicted-identification'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(color: color),
            ),
          ),
        ],
      );
    }

    return Row(
      key: const Key('entry-identification'),
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: identification == null
                  ? theme.colorScheme.surfaceContainerHigh
                  : color.withValues(alpha: 0.16),
              border: Border.all(
                color: identification == null
                    ? theme.colorScheme.outlineVariant
                    : color.withValues(alpha: 0.5),
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Align(alignment: Alignment.centerLeft, child: label),
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          key: const Key('entry-change-identification'),
          onPressed: _openIdentificationSelector,
          child: const Text('Alterar'),
        ),
      ],
    );
  }

  void _schedulePrediction() {
    _predictionDebounce?.cancel();
    _predictionDebounce = Timer(AccountabilityEntryForm.predictionDelay, _predictIfNeeded);
  }

  Future<void> _predictIfNeeded() async {
    final signature = _inputSignature;
    if (signature == null || signature == _predictedSignature) return;
    _predictedSignature = signature;

    final predictionService =
        GetIt.I<AccountabilityIdentificationPredictionService>();
    setState(() => _isPredicting = true);

    try {
      final predicted = await predictionService.predict(
        entries: [
          AccountabilityEntryRequest(
            description: descriptionCtrl.text.trim(),
            value: _parseValue(valueCtrl.text)!,
            createdAt: createdAt,
          ),
        ],
      );
      if (!mounted) return;
      setState(() {
        _isPredicting = false;
        if (!_identificationChosenManually) {
          _identification =
              predicted.isEmpty ? null : predicted.first.identification;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isPredicting = false);
    }
  }

  String? get _inputSignature {
    final description = descriptionCtrl.text.trim();
    final value = _parseValue(valueCtrl.text);
    if (description.isEmpty || value == null) return null;
    return '$description|$value';
  }

  Future<void> _openIdentificationSelector() async {
    final repo = GetIt.I<AccountabilityRepo>();
    final identifications = await repo.getIdentifications();
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (_) => AccountabilityIdentificationSelector(
        identifications: identifications,
        currentIdentificationId: _identification?.id,
        recordDescription: descriptionCtrl.text.trim(),
        recordValue: _parseValue(valueCtrl.text) ?? 0,
        onSelected: (selected) {
          setState(() {
            _identification = selected;
            _identificationChosenManually = true;
          });
        },
      ),
    );
  }

  Future<void> save() async {
    final description = descriptionCtrl.text.trim();
    final valueText = valueCtrl.text.trim();
    final value = _parseValue(valueText);
    final today = DateTime.now();
    final entryDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
    final firstAllowedDate = DateTime(2022);
    final lastAllowedDate = DateTime(today.year, today.month, today.day);
    final validDate = !entryDate.isBefore(firstAllowedDate) &&
        !entryDate.isAfter(lastAllowedDate);

    setState(() {
      descriptionError =
          description.isEmpty ? 'Preencha o campo, por favor' : null;
      valueError = valueText.isEmpty
          ? 'Preencha o campo, por favor'
          : value == null
              ? 'Informe um valor válido'
              : null;
      dateError = validDate ? null : 'Informe uma data válida';
    });

    if (descriptionError != null || valueError != null || dateError != null) {
      return;
    }

    _predictionDebounce?.cancel();
    await _predictIfNeeded();
    if (!mounted) return;
    Navigator.pop(
      context,
      AccountabilityEntryRequest(
        description: description,
        value: value!,
        createdAt: createdAt,
        identification: _identification,
      ),
    );
  }

  double? _parseValue(String value) {
    if (value.trim().isEmpty) return null;

    try {
      final parsed = inputFormatter.parse(value);
      return parsed.isFinite ? parsed : null;
    } on FormatException {
      return null;
    }
  }
}
