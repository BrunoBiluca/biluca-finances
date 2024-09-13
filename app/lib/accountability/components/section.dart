import 'package:biluca_financas/accountability/bloc/bloc.dart';
import 'package:biluca_financas/accountability/bloc/events.dart';
import 'package:biluca_financas/accountability/bloc/states.dart';
import 'package:biluca_financas/accountability/components/entry_form.dart';
import 'package:biluca_financas/accountability/components/table.dart';
import 'package:biluca_financas/accountability/models/entry_request.dart';
import 'package:biluca_financas/predict/predict_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';

class AccountabilitySection extends StatelessWidget {
  const AccountabilitySection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
        mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 250,
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(FontAwesomeIcons.fileImport),
                      SizedBox(width: 20),
                      Text('Importar'),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 20),
              SizedBox(
                width: 250,
                child: TextButton(
                  onPressed: () async {
                    var newEntry = await showDialog<AccountabilityEntryRequest>(
                      context: context,
                      builder: (context) => const AccountabilityEntryForm(),
                    );
                
                    if (newEntry == null) return;
                
                    if (newEntry.identification == null) {
                      var entries = await GetIt.I<PredictService>().predict([newEntry]);
                      newEntry = entries[0];
                    }
                
                    if (!context.mounted) return;
                    context.read<AccountabilityBloc>().add(AddAccountabilityEntry(newEntry));
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline),
                      SizedBox(width: 20),
                      Text('Nova entrada'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BlocBuilder<AccountabilityBloc, AccountabilityState>(
              builder: (context, state) => AccountabilityTable(entries: state.entries),
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () => context.read<AccountabilityBloc>().add(LoadMoreAccountabilityEntries()),
            child: BlocBuilder<AccountabilityBloc, AccountabilityState>(
              builder: (context, state) => Text('(${state.entries.length}) Carregar mais'),
            ),
          ),
        ],
      ),
    );
  }
}
