import 'package:biluca_financas/accountability/bloc/bloc.dart';
import 'package:biluca_financas/accountability/bloc/events.dart';
import 'package:biluca_financas/accountability/bloc/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'components/table.dart';

class AccountabilityPage extends StatelessWidget {
  const AccountabilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AccountabilityBloc>().add(FetchAccountabilityEntries());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Página com Tabela'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20.0),
            margin: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () => context.read<AccountabilityBloc>().add(AddAccountabilityEntry()),
              child: const Text('Adicionar Item'),
            ),
          ),
          Expanded(
            child: BlocBuilder<AccountabilityBloc, AccountabilityState>(
              builder: (context, state) => AccountabilityTable(entries: state.entries),
            ),
          )
        ],
      ),
    );
  }
}
