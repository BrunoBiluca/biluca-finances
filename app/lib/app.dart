import 'package:biluca_financas/accountability/bloc/bloc.dart';
import 'package:biluca_financas/accountability/page.dart';
import 'package:biluca_financas/reports/current_month_card.dart';
import 'package:biluca_financas/reports/current_month_report.dart';
import 'package:biluca_financas/sqlite/current_month_service.dart';
import 'package:biluca_financas/sqlite/db_provider.dart';
import 'package:biluca_financas/sqlite/accountability_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: DBProvider.i.database,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const CircularProgressIndicator();
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Biluca Finanças'),
            ),
            body: Container(
              padding: const EdgeInsets.all(20.0),
              margin: const EdgeInsets.all(20.0),
              child: Column(children: [
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (_) => AccountabilityBloc(
                          repo: SQLiteAccountabilityRepo(snapshot.data!),
                        ),
                        child: const AccountabilityPage(),
                      ),
                    ),
                  ),
                  child: const Text('Prestação de Contas'),
                ),
                const SizedBox(height: 20),
                const CurrentMonthReport(),
              ]),
            ),
          );
        },
      ),
    );
  }
}
