import 'package:biluca_financas/accountability/bloc/bloc.dart';
import 'package:biluca_financas/accountability/bloc/events.dart';
import 'package:biluca_financas/accountability/models/identification.dart';
import 'package:biluca_financas/components/forms/primary_text_field.dart';
import 'package:biluca_financas/components/text_ballon.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AccountabilityIdentificationSelector extends StatefulWidget {
  final AccountabilityBloc accountabilityBloc;
  final List<AccountabilityIdentification> identifications;
  final Function? onEdit;
  const AccountabilityIdentificationSelector({
    super.key,
    required this.accountabilityBloc,
    required this.identifications,
    this.onEdit,
  });

  @override
  State<AccountabilityIdentificationSelector> createState() => _AccountabilityIdentificationSelectorState();
}

class _AccountabilityIdentificationSelectorState extends State<AccountabilityIdentificationSelector> {
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
    super.dispose();
  }

  void updateSearch({String searchValue = ""}) {
    identificationDescription = searchValue;
  }

  bool _onKey(KeyEvent event) {
    final key = event.logicalKey.keyLabel;

    if (event is KeyDownEvent && key == "Arrow Down") {
      setState(() => selectedIdIndex = (selectedIdIndex + 1) % currentIdentifications.length);
    } else if (event is KeyDownEvent && key == "Arrow Up") {
      setState(() => selectedIdIndex = (selectedIdIndex - 1) % currentIdentifications.length);
    } else if (event is KeyDownEvent && key == "Enter") {
      if (selectedIdIndex == -1) {
        return false;
      }
      widget.onEdit?.call(currentIdentifications.elementAt(selectedIdIndex));
      Navigator.pop(context);
    }

    scrollController.animateTo(
      60.0 * selectedIdIndex,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );

    return false;
  }

  List<AccountabilityIdentification> get currentIdentifications => widget.identifications
      .where(
        (i) =>
            identificationDescription.isEmpty ||
            i.description.toLowerCase().contains(identificationDescription.toLowerCase()),
      )
      .sorted((i1, i2) => i1.description.compareTo(i2.description));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text('Editar identificação'),
        content: SizedBox(
          height: 600,
          width: 600,
          child: Column(
            children: [
              PrimaryTextField(
                labelText: currentIdentifications.isEmpty ? 'Criar identificação' : 'Buscar identificação',
                autofocus: true,
                onChanged: (value) {
                  setState(() => updateSearch(searchValue: value));
                },
                validateEmpty: true,
                validateOnTapOutside: false,
                onEditingComplete: () {
                  if (identificationDescription.isEmpty) {
                    return;
                  }
                  widget.onEdit?.call(AccountabilityIdentification(identificationDescription, Colors.black));
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),
              currentIdentifications.isEmpty
                  ? const Text(
                      'Nenhuma identificação encontrada',
                      key: Key('no-identification-found'),
                    )
                  : Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        controller: scrollController,
                        child: Column(
                          children: [
                            ...currentIdentifications.mapIndexed(
                              (index, id) => Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 2,
                                      color: Theme.of(context).colorScheme.inversePrimary,
                                      style: index == selectedIdIndex ? BorderStyle.solid : BorderStyle.none,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        widget.onEdit?.call(id);
                                        Navigator.pop(context);
                                      },
                                      child: TextBallon(
                                        text: id.description,
                                        color: id.color,
                                        onEdit: (String newValue, Color color) => widget.accountabilityBloc.add(
                                          UpdateAccountabilityIdentification(
                                            id
                                              ..color = color
                                              ..description = newValue,
                                          ),
                                        ),
                                        onDelete: () => widget.accountabilityBloc.add(
                                          DeleteAccountabilityIdentification(id.id),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        ));
  }
}
