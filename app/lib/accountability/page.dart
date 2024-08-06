import 'package:biluca_financas/accountability/bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'components/section.dart';

class AccountabilityPage extends StatelessWidget {
  const AccountabilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prestação de Contas'),
      ),
      body: BlocProvider(
        create: (_) => GetIt.I<AccountabilityBloc>(),
        child: const AccountabilitySection(),
      ),
    );
  }
}
