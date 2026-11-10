import 'package:biluca_financas/core/accountability/bloc/accountability_bloc.dart';
import 'package:biluca_financas/core/accountability/bloc/accountability_states.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';

class FakeAccountabilityBloc extends AccountabilityBloc {
  FakeAccountabilityBloc({required super.repo});

  void emitIdentifications(List<AccountabilityIdentification> identifications) {
    emit(AccountabilityChanged(
      entries: const [],
      identifications: identifications,
    ));
  }
}
