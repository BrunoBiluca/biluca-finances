import 'package:biluca_financas/core/accountability/bloc/accountability_bloc.dart';
import 'package:biluca_financas/core/accountability/bloc/accountability_states.dart';
import 'package:biluca_financas/app/accountability_table/widgets/accountability_identification_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';

class AccountabilityIdentificationLabel extends StatefulWidget {
  final AccountabilityIdentification? identification;
  final Function onEdit;

  const AccountabilityIdentificationLabel(
      {super.key, required this.identification, required this.onEdit});

  @override
  State<AccountabilityIdentificationLabel> createState() =>
      _AccountabilityIdentificationLabelState();
}

class _AccountabilityIdentificationLabelState
    extends State<AccountabilityIdentificationLabel> {
  @override
  Widget build(BuildContext c) {
    final theme = Theme.of(c);
    final identification = widget.identification;
    final color = identification?.color ?? theme.colorScheme.onSurfaceVariant;
    return GestureDetector(
      onTap: () {
        var bloc = c.read<AccountabilityBloc>();
        showDialog(
          context: c,
          builder: (context) =>
              BlocBuilder<AccountabilityBloc, AccountabilityState>(
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
      child: Container(
        key: const Key('accountability-identification-label'),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              identification?.icon ?? Icons.help_outline,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                identification?.description ?? 'Não identificado',
                key: identification == null
                    ? const Key('no-identification')
                    : null,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
