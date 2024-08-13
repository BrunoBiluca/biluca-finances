import 'dart:io';

import 'package:biluca_financas/accountability/page.dart';
import 'package:biluca_financas/reports/current_month_report.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

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
            Row(children: [
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
                  final file = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['csv'],
                  );
                  if (file == null) return;

                  final contents = await File(file.files.single.path!).readAsString();
                  print(contents);
                },
                child: const Text('Carregar Arquivo CSV'),
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
