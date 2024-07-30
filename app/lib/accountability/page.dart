import 'package:biluca_financas/accountability/bloc/bloc.dart';
import 'package:biluca_financas/accountability/bloc/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'components/section.dart';

class AccountabilityPage extends StatelessWidget {
  const AccountabilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AccountabilityBloc>().add(FetchAccountabilityEntries());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prestação de Contas'),
      ),
      body: const AccountabilitySection(),
    );
  }
}
