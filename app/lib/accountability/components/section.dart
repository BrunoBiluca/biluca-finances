import 'package:biluca_financas/accountability/bloc/bloc.dart';
import 'package:biluca_financas/accountability/bloc/events.dart';
import 'package:biluca_financas/accountability/bloc/states.dart';
import 'package:biluca_financas/accountability/components/table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountabilitySection extends StatelessWidget {
  const AccountabilitySection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () => context.read<AccountabilityBloc>().add(AddAccountabilityEntry()),
          child: const Text('Adicionar Item'),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: BlocBuilder<AccountabilityBloc, AccountabilityState>(
            builder: (context, state) => AccountabilityTable(entries: state.entries),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => context.read<AccountabilityBloc>().add(LoadMoreAccountabilityEntries()),
          child: BlocBuilder<AccountabilityBloc, AccountabilityState>(
            builder: (context, state) => Text('(${state.entries.length}) Carregar mais'),
          ),
        ),
      ],
    );
  }
}
