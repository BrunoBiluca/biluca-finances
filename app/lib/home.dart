import 'dart:io';

import 'package:biluca_financas/accountability/page.dart';
import 'package:biluca_financas/accountability/services/import_service.dart';
import 'package:biluca_financas/reports/current_month_report.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'components/base_toast.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biluca Finanças'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        margin: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountabilityPage(),
                  ),
                ).whenComplete(
                  () => setState(() {}),
                ),
                child: const Text('Prestação de Contas'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['csv'],
                  );
                  if (result == null) return;

                  var file = File(result.files.single.path!);
                  await GetIt.I<AccountabilityImportService>().import(file);
                  GetIt.I<FToast>().showToast(
                    child: const BaseToast(text: "Arquivo importado"),
                    gravity: ToastGravity.TOP,
                    toastDuration: const Duration(seconds: 2),
                  );
                },
                child: const Text('Importar'),
              ),
            ]),
            const SizedBox(height: 20),
            Expanded(child: CurrentMonthReport()),
          ],
        ),
      ),
    );
  }
}
