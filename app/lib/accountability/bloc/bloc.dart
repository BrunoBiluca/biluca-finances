import 'package:biluca_financas/accountability/bloc/events.dart';
import 'package:biluca_financas/accountability/bloc/states.dart';
import 'package:biluca_financas/sqlite/sqlite_accountability_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountabilityBloc extends Bloc<AccountabilityEvent, AccountabilityState> {
  final SQLiteAccountabilityRepo repo;

  AccountabilityBloc({required this.repo}) : super(const AccountabilityInitial()) {
    on<FetchAccountabilityEntries>((event, emit) async {
      emit(const AccountabilityInitial());
      emit(AccountabilityChanged(
        entries: await repo.getEntries(),
        identifications: await repo.getIdentifications(),
      ));
    });

    on<AddAccountabilityEntry>((event, emit) async {
      await repo.add(event.request);
      emit(AccountabilityChanged(
        entries: await repo.getEntries(),
        identifications: await repo.getIdentifications(),
      ));
    });

    on<DeleteAccountabilityEntry>((event, emit) async {
      await repo.delete(event.entry);
      emit(AccountabilityChanged(
        entries: await repo.getEntries(),
        identifications: await repo.getIdentifications(),
      ));
    });

    on<UpdateAccountabilityEntry>((event, emit) async {
      await repo.update(event.updatedEntry);
      emit(AccountabilityChanged(
        entries: await repo.getEntries(),
        identifications: await repo.getIdentifications(),
      ));
    });

    on<UpdateAccountabilityIdentification>((event, emit) async {
      await repo.updateIdentification(event.updatedIdentification);
      emit(AccountabilityChanged(
        entries: await repo.getEntries(),
        identifications: await repo.getIdentifications(),
      ));
    });

    on<DeleteAccountabilityIdentification>((event, emit) async {
      await repo.deleteIdentification(event.identificationId);
      emit(AccountabilityChanged(
        entries: await repo.getEntries(),
        identifications: await repo.getIdentifications(),
      ));
    });
  }


}
