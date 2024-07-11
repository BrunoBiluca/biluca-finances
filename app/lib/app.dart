import 'package:biluca_financas/accountability/bloc/bloc.dart';
import 'package:biluca_financas/accountability/page.dart';
import 'package:biluca_financas/sqlite/db_provider.dart';
import 'package:biluca_financas/sqlite/sqlite_accountability_repo.dart';
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

          return BlocProvider(
            create: (_) => AccountabilityBloc(
              repo: SQLiteAccountabilityRepo(snapshot.data!),
            ),
            
            child: const AccountabilityPage(),
          );
        },
      ),
    );
  }
}
