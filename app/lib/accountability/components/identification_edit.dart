import 'package:biluca_financas/accountability/bloc/bloc.dart';
import 'package:biluca_financas/accountability/bloc/states.dart';
import 'package:biluca_financas/accountability/components/identification_edit_selector.dart';
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
  @override
  Widget build(BuildContext c) {
    return GestureDetector(
      onTap: () {
        var bloc = c.read<AccountabilityBloc>();
        showDialog(
          context: c,
          builder: (context) => BlocBuilder<AccountabilityBloc, AccountabilityState>(
            bloc: bloc,
            builder: (context, state) {
              return AccountabilityIdentificationSelector(
                accountabilityBloc: bloc,
                identifications: state.identifications,
                onEdit: widget.onEdit,
              );
            },
          ),
        );
      },
      child: widget.identification == null
          ? Text(
              'Não identificado',
              key: const Key('no-identification'),
              textAlign: TextAlign.center,
              style: Theme.of(c).textTheme.bodySmall,
            )
          : TextBallon(
              icon: widget.identification!.icon,
              text: widget.identification!.description,
              color: widget.identification!.color,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            ),
    );
  }
}
