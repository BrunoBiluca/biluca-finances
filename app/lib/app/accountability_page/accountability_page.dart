import 'dart:io';
import 'package:biluca_financas/core/accountability/bloc/accountability_bloc.dart';
import 'package:biluca_financas/core/accountability/bloc/accountability_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:biluca_financas/core/accountability/bloc/accountability_states.dart';
import 'package:biluca_financas/app/accountability_new_entry_form/accountability_new_entry_form.dart';
import 'package:biluca_financas/app/accountability_table/accountability_table.dart';
import 'package:biluca_financas/app/accountability_import_verification/accountability_import_verification.dart';
import 'package:biluca_financas/core/accountability/models/accountability_entry_request.dart';
import 'package:biluca_financas/core/accountability_import/services/accountability_import_service.dart';
import 'package:biluca_financas/components/base_toast.dart';
import 'package:biluca_financas/integrations/embedded_server/embedded_predict_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AccountabilityPage extends StatelessWidget {
  const AccountabilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<AccountabilityBloc>()..add(FetchAccountabilityEntries()),
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
        child: AccountabilityImportVerification(service: importService),
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
      var entries = await GetIt.I<EmbeddedPredictService>().predict(entries: [newEntry]);
      newEntry = entries[0];
    }

    if (!context.mounted) return;
    context.read<AccountabilityBloc>().add(AddAccountabilityEntry(newEntry));
  }
}
