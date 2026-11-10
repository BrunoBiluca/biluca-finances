import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:biluca_financas/core/accountability/validators/identification_availability_rules.dart';
import 'package:biluca_financas/common/ui/base_dialog.dart';
import 'package:biluca_financas/common/ui/forms/primary_text_field.dart';
import 'package:biluca_financas/common/ui/text_ballon.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AccountabilityIdentificationSelector extends StatefulWidget {
  final List<AccountabilityIdentification> identifications;
  final String? currentIdentificationId;
  final ValueChanged<AccountabilityIdentification> onSelected;

  const AccountabilityIdentificationSelector({
    super.key,
    required this.identifications,
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
  }

  bool _onKey(KeyEvent event) {
    final identifications = currentIdentifications;
    if (identifications.isEmpty) return false;

    final key = event.logicalKey.keyLabel;

    if (event is KeyDownEvent && key == "Arrow Down") {
      setState(() =>
          selectedIdIndex = (selectedIdIndex + 1) % identifications.length);
    } else if (event is KeyDownEvent && key == "Arrow Up") {
      setState(() =>
          selectedIdIndex = (selectedIdIndex - 1) % identifications.length);
    } else if (event is KeyDownEvent && key == "Enter") {
      if (selectedIdIndex < 0 || selectedIdIndex >= identifications.length) {
        return false;
      }
      _select(identifications.elementAt(selectedIdIndex));
      return false;
    }

    if (scrollController.hasClients && selectedIdIndex >= 0) {
      scrollController.animateTo(
        60.0 * selectedIdIndex,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
    }

    return false;
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

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: 'Selecionar identificação',
      content: SizedBox(
        height: 600,
        width: 600,
        child: Column(
          children: [
            PrimaryTextField(
              labelText: 'Buscar identificação',
              autofocus: true,
              onChanged: (value) {
                setState(() => updateSearch(searchValue: value));
              },
              validateEmpty: false,
              validateOnTapOutside: false,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                controller: scrollController,
                child: currentIdentifications.isEmpty
                    ? const Text(
                        'Nenhuma identificação encontrada',
                        key: Key('no-identification-found'),
                      )
                    : Column(
                        children: [
                          ...currentIdentifications.mapIndexed(
                            (index, identification) => renderIdentificationItem(
                              context,
                              index,
                              identification,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding renderIdentificationItem(
    BuildContext context,
    int index,
    AccountabilityIdentification identification,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: Theme.of(context).colorScheme.inversePrimary,
            style:
                index == selectedIdIndex ? BorderStyle.solid : BorderStyle.none,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: GestureDetector(
            onTap: () => _select(identification),
            child: TextBallon(
              key: Key('identification-item-${identification.id}'),
              icon: identification.icon,
              text: identification.description,
              color: identification.color,
              tintedStyle: true,
            ),
          ),
        ),
      ),
    );
  }
}
