import 'package:biluca_financas/accountability/bloc/bloc.dart';
import 'package:biluca_financas/accountability/bloc/events.dart';
import 'package:biluca_financas/accountability/bloc/states.dart';
import 'package:biluca_financas/components/forms/primary_text_field.dart';
import 'package:biluca_financas/components/text_ballon.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/identification.dart';

class AccountabilityIdentificationEdit extends StatefulWidget {
  final AccountabilityIdentification? identification;
  final Function onEdit;

  const AccountabilityIdentificationEdit({super.key, required this.identification, required this.onEdit});

  @override
  State<AccountabilityIdentificationEdit> createState() => _AccountabilityIdentificationEditState();
}

class _AccountabilityIdentificationEditState extends State<AccountabilityIdentificationEdit> {
  late TextEditingController controller;
  late AccountabilityBloc accountabilityBloc;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    accountabilityBloc = context.read<AccountabilityBloc>();
  }

  void close() {
    controller.clear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Editar Texto'),
            content: SizedBox(
              height: 600,
              width: 600,
              child: Column(
                children: [
                  PrimaryTextField(
                    labelText: 'Nova Identificação',
                    controller: controller,
                    autofocus: true,
                    onEditingComplete: () {
                      widget.onEdit(AccountabilityIdentification(controller.text, Colors.black));
                      close();
                    },
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<AccountabilityBloc, AccountabilityState>(
                    bloc: accountabilityBloc,
                    builder: (context, state) {
                      var identifications = state.identifications;
                      if (identifications.isEmpty) {
                        return const Text('Nenhuma identificação encontrada');
                      }

                      identifications = identifications.sorted((i1, i2) => i1.description.compareTo(i2.description));

                      return Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            children: [
                              ...identifications.map(
                                (i) => Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      widget.onEdit(i);
                                      close();
                                    },
                                    child: TextBallon(
                                      text: i.description,
                                      color: i.color,
                                      onEdit: (String newValue, Color color) => accountabilityBloc.add(
                                        UpdateAccountabilityIdentification(
                                          i
                                            ..color = color
                                            ..description = newValue,
                                        ),
                                      ),
                                      onDelete: () => accountabilityBloc.add(
                                        DeleteAccountabilityIdentification(i.id),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: widget.identification == null
          ? Text(
              'Não identificado',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            )
          : SizedBox(
              height: 32,
              width: 200,
              child: TextBallon(
                text: widget.identification!.description,
                color: widget.identification!.color,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              ),
            ),
    );
  }
}
