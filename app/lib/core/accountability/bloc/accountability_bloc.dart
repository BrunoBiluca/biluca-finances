import 'package:biluca_financas/core/accountability/bloc/accountability_events.dart';
import 'package:biluca_financas/core/accountability/bloc/accountability_states.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:biluca_financas/core/accountability/services/accountability_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountabilityBloc extends Bloc<AccountabilityEvent, AccountabilityState> {
  final AccountabilityRepo repo;
  int get limit => loadedPages * 100;
  int loadedPages = 1;
  AccountabilityIdentification? currentIdentification;

  AccountabilityBloc({required this.repo}) : super(const AccountabilityInitial()) {
    on<FetchAccountabilityEntries>((event, emit) async {
      if (event.identification != null) {
        currentIdentification = event.identification;
      }

      await updateEntries(emit);
    });

    on<LoadMoreAccountabilityEntries>((event, emit) async {
      loadedPages += 1;
      await updateEntries(emit);
    });

    on<AddAccountabilityEntry>((event, emit) async {
      await repo.add(event.request);
      await updateEntries(emit);
    });

    on<DeleteAccountabilityEntry>((event, emit) async {
      await repo.delete(event.entry);
      await updateEntries(emit);
    });

    on<UpdateAccountabilityEntry>((event, emit) async {
      await repo.update(event.updatedEntry);
      await updateEntries(emit);
    });

    on<UpdateAccountabilityIdentification>((event, emit) async {
      await repo.updateIdentification(event.updatedIdentification);
      await updateEntries(emit);
    });

    on<DeleteAccountabilityIdentification>((event, emit) async {
      await repo.deleteIdentification(event.identificationId);
      await updateEntries(emit);
    });
  }

  Future<void> updateEntries(Emitter<AccountabilityState> emit) async {
    if (currentIdentification != null) {
      emit(AccountabilityChanged(
        entries: await repo.getEntriesByIdentification(currentIdentification!),
        identifications: await repo.getIdentifications(),
      ));
      return;
    }

    emit(AccountabilityChanged(
      entries: await repo.getEntries(limit: limit),
      identifications: await repo.getIdentifications(),
    ));
  }
}
