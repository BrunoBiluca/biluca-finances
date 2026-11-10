import 'dart:math' as math;

import 'package:biluca_financas/app/accountability_import_verification/widgets/accountability_import_header.dart';
import 'package:biluca_financas/app/accountability_import_verification/widgets/accountability_import_tab_bar.dart';
import 'package:biluca_financas/app/accountability_import_verification/widgets/accountability_import_table_tab.dart';
import 'package:biluca_financas/app/accountability_import_verification/widgets/applied_rules_placeholder.dart';
import 'package:biluca_financas/common/navigation/mouse_back_button_listener.dart';
import 'package:biluca_financas/core/accountability/bloc/accountability_bloc.dart';
import 'package:biluca_financas/core/accountability/bloc/accountability_states.dart';
import 'package:biluca_financas/core/accountability/models/accountability_entry.dart';
import 'package:biluca_financas/core/accountability_import/services/accountability_import_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountabilityImportVerification extends StatefulWidget {
  static const String defaultFileName = 'Arquivo importado';

  final AccountabilityImportService service;
  final String? sourceFileName;

  const AccountabilityImportVerification({
    super.key,
    required this.service,
    this.sourceFileName,
  });

  @override
  State<AccountabilityImportVerification> createState() =>
      _AccountabilityImportVerificationState();
}

class _AccountabilityImportVerificationState
    extends State<AccountabilityImportVerification> {
  double get _netBalance => widget.service.entries.fold<double>(
        0,
        (sum, entry) => sum + entry.value,
      );

  String get _sourceFileName {
    final fileName = widget.sourceFileName?.trim();
    if (fileName == null || fileName.isEmpty) {
      return AccountabilityImportVerification.defaultFileName;
    }
    return fileName;
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final width = math.min(math.max(screen.width - 48, 320.0), 1400.0);
    final height = math.min(
      math.min(screen.height * 0.92, 960.0),
      math.max(screen.height - 48, 320.0),
    );

    return MouseBackButtonListener(
      child: Dialog(
        insetPadding: const EdgeInsets.all(24),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: width,
          height: height,
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                AccountabilityImportHeader(
                  sourceFileName: _sourceFileName,
                  netBalance: _netBalance,
                  onClose: () => Navigator.pop(context),
                ),
                AccountabilityImportTabBar(
                  newEntriesCount: widget.service.entries.length,
                  duplicatedEntriesCount:
                      widget.service.duplicatedEntries.length,
                ),
                Expanded(
                  child: BlocBuilder<AccountabilityBloc, AccountabilityState>(
                    builder: (context, state) {
                      return TabBarView(
                        children: [
                          AccountabilityImportTableTab(
                            tableKey: const Key('import-new-entries-table'),
                            entries: widget.service.entries,
                            identifications: state.identifications,
                            onUpdate: _updateEntry,
                            onRemove: _removeEntry,
                          ),
                          AccountabilityImportTableTab(
                            tableKey: const Key('import-duplicates-table'),
                            entries: widget.service.duplicatedEntries,
                            identifications: state.identifications,
                            onUpdate: _updateDuplicatedEntry,
                            onRemove: _discardDuplication,
                            showInsertedAt: true,
                            removeIcon: Icons.arrow_upward_rounded,
                            removeTooltip: 'Desconsiderar duplicata',
                          ),
                          const AppliedRulesPlaceholder(),
                        ],
                      );
                    },
                  ),
                ),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    final summary = Text(
      '${widget.service.entries.length} entradas serão importadas',
      key: const Key('import-entries-summary'),
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );

    final cancelButton = OutlinedButton(
      key: const Key('cancel-import-verification'),
      onPressed: () => Navigator.pop(context),
      child: const Text('Cancelar'),
    );

    // Keep the filled action radius aligned with the outlined button from the theme.
    final saveButton = FilledButton.icon(
      key: const Key('save-import-verification'),
      onPressed: () async {
        await widget.service.save();
        if (context.mounted) Navigator.pop(context);
      },
      icon: const Icon(Icons.check),
      label: const Text('Salvar'),
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 560) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                summary,
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: cancelButton),
                    const SizedBox(width: 12),
                    Expanded(child: saveButton),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: summary),
              const SizedBox(width: 12),
              cancelButton,
              const SizedBox(width: 12),
              saveButton,
            ],
          );
        },
      ),
    );
  }

  void _updateEntry(dynamic updatedEntry) {
    final index = widget.service.entries.indexOf(updatedEntry);
    if (index == -1) return;
    setState(() => widget.service.entries[index] = updatedEntry);
  }

  void _removeEntry(dynamic entry) {
    setState(() => widget.service.entries.remove(entry));
  }

  void _updateDuplicatedEntry(dynamic updatedEntry) {
    final index = widget.service.duplicatedEntries.indexOf(updatedEntry);
    if (index == -1) return;
    setState(() => widget.service.duplicatedEntries[index] = updatedEntry);
  }

  void _discardDuplication(dynamic entry) {
    setState(
      () => widget.service.cancelDuplication(entry as AccountabilityEntry),
    );
  }
}
