import 'package:biluca_financas/core/accountability/bloc/accountability_bloc.dart';
import 'package:biluca_financas/core/accountability/bloc/accountability_states.dart';
import 'package:biluca_financas/app/accountability_table/widgets/accountability_identification_selector.dart';
import 'package:biluca_financas/components/text_ballon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/accountability/models/accountability_identification.dart';

class AccountabilityIdentificationLabel extends StatefulWidget {
  final AccountabilityIdentification? identification;
  final Function onEdit;

  const AccountabilityIdentificationLabel({super.key, required this.identification, required this.onEdit});

  @override
  State<AccountabilityIdentificationLabel> createState() => _AccountabilityIdentificationLabelState();
}

class _AccountabilityIdentificationLabelState extends State<AccountabilityIdentificationLabel> {
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
