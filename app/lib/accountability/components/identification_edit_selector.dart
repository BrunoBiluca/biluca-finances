import 'package:biluca_financas/accountability/bloc/bloc.dart';
import 'package:biluca_financas/accountability/bloc/events.dart';
import 'package:biluca_financas/accountability/bloc/states.dart';
import 'package:biluca_financas/accountability/models/identification.dart';
import 'package:biluca_financas/components/forms/primary_text_field.dart';
import 'package:biluca_financas/components/text_ballon.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountabilityIdentificationSelector extends StatefulWidget {
  final AccountabilityBloc accountabilityBloc;
  final Function? onEdit;
  const AccountabilityIdentificationSelector({
    super.key,
    required this.accountabilityBloc,
    this.onEdit,
  });

  @override
  State<AccountabilityIdentificationSelector> createState() => _AccountabilityIdentificationSelectorState();
}

class _AccountabilityIdentificationSelectorState extends State<AccountabilityIdentificationSelector> {
  String identificationDescription = "";

  @override
  void initState() {
    super.initState();
    updateSearch(searchValue: "");
  }

  void updateSearch({String searchValue = ""}) {
    identificationDescription = searchValue;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar identificação'),
      content: BlocBuilder<AccountabilityBloc, AccountabilityState>(
        bloc: widget.accountabilityBloc,
        builder: (context, state) {
          var currentIdentifications = state.identifications
              .where(
                (i) =>
                    identificationDescription.isEmpty ||
                    i.description.toLowerCase().contains(identificationDescription.toLowerCase()),
              )
              .sorted((i1, i2) => i1.description.compareTo(i2.description));

          return SizedBox(
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
                          child: Column(
                            children: [
                              ...currentIdentifications.map(
                                (i) => Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      widget.onEdit?.call(i);
                                      Navigator.pop(context);
                                    },
                                    child: TextBallon(
                                      text: i.description,
                                      color: i.color,
                                      onEdit: (String newValue, Color color) => widget.accountabilityBloc.add(
                                        UpdateAccountabilityIdentification(
                                          i
                                            ..color = color
                                            ..description = newValue,
                                        ),
                                      ),
                                      onDelete: () => widget.accountabilityBloc.add(
                                        DeleteAccountabilityIdentification(i.id),
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
          );
        },
      ),
    );
  }
}
