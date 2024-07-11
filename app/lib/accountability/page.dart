import 'package:biluca_financas/accountability/bloc/bloc.dart';
import 'package:biluca_financas/accountability/bloc/events.dart';
import 'package:biluca_financas/accountability/bloc/states.dart';
import 'package:biluca_financas/accountability/models/entry_request.dart';
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
        children: [
          ElevatedButton(
            onPressed: () {
              var bloc = context.read<AccountabilityBloc>();
              bloc.add(
                AddAccountabilityEntry(
                  AccountabilityEntryRequest(
                    description: "Descricão fictício",
                    value: 10.00,
                    createdAt: DateTime.now(),
                  ),
                ),
              );
            },
            child: const Text('Adicionar Item'),
          ),
          BlocBuilder<AccountabilityBloc, AccountabilityState>(
            builder: (context, state) => AccountabilityTable(entries: state.entries),
          ),
        ],
      ),
    );
  }
}
