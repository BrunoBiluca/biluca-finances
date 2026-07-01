import 'package:biluca_financas/accountability/bloc/bloc.dart';
import 'package:biluca_financas/accountability/bloc/events.dart';
import 'package:biluca_financas/components/mouse_back_button_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'components/section.dart';

class AccountabilityPage extends StatelessWidget {
  const AccountabilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MouseBackButtonListener(
      child: BlocProvider(
        create: (_) => GetIt.I<AccountabilityBloc>()..add(FetchAccountabilityEntries()),
        child: const AccountabilitySection(),
      ),
    );
  }
}
