import 'dart:io';

import 'package:biluca_financas/accountability/bloc/bloc.dart';
import 'package:biluca_financas/accountability/bloc/events.dart';
import 'package:biluca_financas/accountability/bloc/states.dart';
import 'package:biluca_financas/accountability/components/entry_form.dart';
import 'package:biluca_financas/accountability/components/table.dart';
import 'package:biluca_financas/accountability/import_check_page.dart';
import 'package:biluca_financas/accountability/models/entry_request.dart';
import 'package:biluca_financas/accountability/services/import_service.dart';
import 'package:biluca_financas/components/base_toast.dart';
import 'package:biluca_financas/predict/predict_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';

class AccountabilitySection extends StatelessWidget {
  const AccountabilitySection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 250,
                child: OutlinedButton(
                  onPressed: () => import(context),
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
              const SizedBox(width: 20),
              SizedBox(
                width: 250,
                child: TextButton(
                  onPressed: () => newEntry(context),
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
              builder: (context, state) {
                if (state.entries.isEmpty) {
                  return const Center(child: Text('Nenhuma entrada registrada'));
                }

                return AccountabilityTable(
                  entries: state.entries,
                  onUpdate: (entry) => context.read<AccountabilityBloc>().add(UpdateAccountabilityEntry(entry)),
                  onRemove: (entry) => context.read<AccountabilityBloc>()..add(DeleteAccountabilityEntry(entry)),
                );
              },
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

  void import(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null) return;

    var file = File(result.files.single.path!);
    var importService = GetIt.I<AccountabilityImportService>();
    await importService.import(file);
    GetIt.I<FToast>().showToast(
      child: const BaseToast(text: "Arquivo importado"),
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 2),
    );

    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (c) => BlocProvider(
        create: (_) => GetIt.I<AccountabilityBloc>()..add(FetchAccountabilityEntries()),
        child: AccountabilityImportCheckPage(service: importService),
      ),
    );
  }

  void newEntry(BuildContext context) async {
    var newEntry = await showDialog<AccountabilityEntryRequest>(
      context: context,
      builder: (context) => const AccountabilityEntryForm(),
    );

    if (newEntry == null) return;

    if (newEntry.identification == null) {
      var entries = await GetIt.I<PredictService>().predict(entries: [newEntry]);
      newEntry = entries[0];
    }

    if (!context.mounted) return;
    context.read<AccountabilityBloc>().add(AddAccountabilityEntry(newEntry));
  }
}
