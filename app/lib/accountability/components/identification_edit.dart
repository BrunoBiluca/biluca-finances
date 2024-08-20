import 'package:biluca_financas/accountability/bloc/bloc.dart';
import 'package:biluca_financas/accountability/bloc/events.dart';
import 'package:biluca_financas/accountability/bloc/states.dart';
import 'package:biluca_financas/components/text_ballon.dart';
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
            content: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Nova Identificação'),
                  autofocus: true,
                  controller: controller,
                  onEditingComplete: () {
                    widget.onEdit(AccountabilityIdentification(controller.text, Colors.black));
                    close();
                  },
                ),
                BlocBuilder<AccountabilityBloc, AccountabilityState>(
                  bloc: accountabilityBloc,
                  builder: (context, state) {
                    var identifications = state.identifications;
                    if (identifications.isEmpty) {
                      return const Text('Nenhuma identificação encontrada');
                    }

                    return Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                            ...identifications.map(
                              (identification) => GestureDetector(
                                onTap: () {
                                  widget.onEdit(identification);
                                  close();
                                },
                                child: TextBallon(
                                  text: identification.description,
                                  color: identification.color,
                                  onEdit: (String newValue, Color color) => accountabilityBloc.add(
                                    UpdateAccountabilityIdentification(
                                      identification
                                        ..color = color
                                        ..description = newValue,
                                    ),
                                  ),
                                  onDelete: () => accountabilityBloc.add(
                                    DeleteAccountabilityIdentification(identification.id),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: widget.identification == null
          ? const Text('Não identificado')
          : TextBallon(
              text: widget.identification!.description,
              color: widget.identification!.color,
            ),
    );
  }
}
