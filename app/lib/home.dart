
import 'package:biluca_financas/main_drawner.dart';
import 'package:biluca_financas/reports/current_month_report.dart';
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
        title: Text(
          'Biluca Finanças',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
      body: Row(
        children: [
          const SizedBox(
            width: 250,
            child: MainDrawner(),
          ),
          Container(
            padding: const EdgeInsets.all(20.0),
            margin: const EdgeInsets.all(20.0),
            child: CurrentMonthReport(),
          ),
        ],
      ),
    );
  }
}


                    // ElevatedButton(
                    //   onPressed: () async {
                    //     final result = await FilePicker.platform.pickFiles(
                    //       type: FileType.custom,
                    //       allowedExtensions: ['csv'],
                    //     );
                    //     if (result == null) return;

                    //     var file = File(result.files.single.path!);
                    //     var importService = GetIt.I<AccountabilityImportService>();
                    //     await importService.import(file);
                    //     GetIt.I<FToast>().showToast(
                    //       child: const BaseToast(text: "Arquivo importado"),
                    //       gravity: ToastGravity.TOP,
                    //       toastDuration: const Duration(seconds: 2),
                    //     );

                    //     if (!context.mounted) return;

                    //     await showDialog(
                    //       context: context,
                    //       builder: (c) => AccountabilityImportCheckPage(service: importService),
                    //     );
                    //   },
                    //   child: const Text('Importar'),
                    // ),
