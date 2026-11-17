import 'dart:math' as math;

import 'package:biluca_financas/common/extensions/color_extensions.dart';
import 'package:biluca_financas/common/navigation/mouse_back_button_listener.dart';
import 'package:biluca_financas/common/ui/real_currency.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:biluca_financas/core/accountability/validators/identification_availability_rules.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class AccountabilityIdentificationSelector extends StatefulWidget {
  final List<AccountabilityIdentification> identifications;
  final String? currentIdentificationId;
  final String recordDescription;
  final double recordValue;
  final ValueChanged<AccountabilityIdentification> onSelected;

  const AccountabilityIdentificationSelector({
    super.key,
    required this.identifications,
    required this.recordDescription,
    required this.recordValue,
    required this.onSelected,
    this.currentIdentificationId,
  });

  @override
  State<AccountabilityIdentificationSelector> createState() =>
      _AccountabilityIdentificationSelectorState();
}

class _AccountabilityIdentificationSelectorState
    extends State<AccountabilityIdentificationSelector> {
  String identificationDescription = "";
  int selectedIdIndex = -1;
  ScrollController scrollController = ScrollController();
  final Map<String, GlobalKey> _identificationKeys = {};

  @override
  void initState() {
    super.initState();
    ServicesBinding.instance.keyboard.addHandler(_onKey);
    updateSearch(searchValue: "");
  }

  @override
  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(_onKey);
    scrollController.dispose();
    super.dispose();
  }

  void updateSearch({String searchValue = ""}) {
    identificationDescription = searchValue;
    selectedIdIndex = -1;
    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
  }

  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;

    final identifications = currentIdentifications;
    if (identifications.isEmpty) return false;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        selectedIdIndex = (selectedIdIndex + 1) % identifications.length;
      });
      _ensureSelectedItemVisible(identifications[selectedIdIndex]);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        selectedIdIndex = selectedIdIndex <= 0
            ? identifications.length - 1
            : selectedIdIndex - 1;
      });
      _ensureSelectedItemVisible(identifications[selectedIdIndex]);
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (selectedIdIndex < 0 || selectedIdIndex >= identifications.length) {
        return false;
      }
      _select(identifications[selectedIdIndex]);
    }

    return false;
  }

  void _ensureSelectedItemVisible(
    AccountabilityIdentification identification,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final itemContext =
          _identificationKeys[identification.id]?.currentContext;
      if (itemContext != null) {
        Scrollable.ensureVisible(
          itemContext,
          alignment: 0.5,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  List<AccountabilityIdentification> get currentIdentifications =>
      IdentificationAvailabilityRules.optionsForSelection(
        identifications: widget.identifications,
        currentIdentificationId: widget.currentIdentificationId,
      )
          .where(
            (identification) =>
                identificationDescription.isEmpty ||
                identification.description
                    .toLowerCase()
                    .contains(identificationDescription.toLowerCase()),
          )
          .sorted(
            (first, second) => first.description.compareTo(second.description),
          );

  void _select(AccountabilityIdentification identification) {
    widget.onSelected(identification);
    Navigator.pop(context);
  }

  void _openIdentificationSettings() {
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.push('/identifications');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.sizeOf(context);
    final availableHeight =
        screenSize.height - MediaQuery.viewInsetsOf(context).bottom - 80;

    return MouseBackButtonListener(
      child: Dialog(
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: math.min(1000.0, math.max(220.0, availableHeight * 0.8)),
          width: math.min(560.0, math.max(280.0, screenSize.width - 64)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: double.infinity,
                color: theme.scaffoldBackgroundColor,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selecionar identificação',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.recordDescription,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RealCurrency(
                      number: widget.recordValue,
                    )
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        autofocus: true,
                        onChanged: (value) {
                          setState(() => updateSearch(searchValue: value));
                        },
                        decoration: InputDecoration(
                          hintText: 'Buscar identificação...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerLow,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              width: 0.5,
                              color: theme.colorScheme.outlineVariant,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.colorScheme.outlineVariant,
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _buildIdentificationList(context),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                color: theme.scaffoldBackgroundColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    key: const Key('open-identification-settings'),
                    onPressed: _openIdentificationSettings,
                    icon: const Icon(Icons.settings_outlined),
                    label: const Text('Configurar identificações'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdentificationList(BuildContext context) {
    final identifications = currentIdentifications;
    if (identifications.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma identificação encontrada',
          key: Key('no-identification-found'),
        ),
      );
    }

    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: identifications
            .mapIndexed(
              (index, identification) =>
                  _buildIdentificationItem(context, index, identification),
            )
            .toList(),
      ),
    );
  }

  Widget _buildIdentificationItem(
    BuildContext context,
    int index,
    AccountabilityIdentification identification,
  ) {
    final theme = Theme.of(context);
    final isHighlighted = index == selectedIdIndex;
    final isCurrent = identification.id == widget.currentIdentificationId;
    final detailText = identification.descriptionDetail.trim();
    final itemColor = identification.color;

    return Padding(
      key: _identificationKeys.putIfAbsent(
        identification.id,
        GlobalKey.new,
      ),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        key: Key('identification-item-${identification.id}'),
        color: itemColor.withValues(alpha: isHighlighted ? 0.16 : 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color:
                isHighlighted ? itemColor : itemColor.withValues(alpha: 0.35),
            width: isHighlighted ? 2 : 0.5,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _select(identification),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: itemColor.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(identification.icon, color: itemColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        identification.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: itemColor.addBrightness(150),
                        ),
                      ),
                      if (detailText.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          detailText,
                          softWrap: true,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: itemColor.addBrightness(50),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isCurrent) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.check_circle,
                    key: Key('identification-current-${identification.id}'),
                    color: itemColor,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
