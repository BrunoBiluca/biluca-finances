import 'package:biluca_financas/core/accountability/bloc/accountability_events.dart';
import 'package:biluca_financas/core/accountability/bloc/accountability_states.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:biluca_financas/core/accountability/services/accountability_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountabilityBloc
    extends Bloc<AccountabilityEvent, AccountabilityState> {
  final AccountabilityRepo repo;
  static const int pageSize = 100;
  int loadedPages = 1;
  AccountabilityIdentification? currentIdentification;
  String currentSearchQuery = '';
  String? currentIdentificationId;
  int _queryVersion = 0;
  int _entryCreationVersion = 0;
  bool _isSearchMode = false;

  int get limit => loadedPages * pageSize;

  AccountabilityBloc({required this.repo})
      : super(const AccountabilityInitial()) {
    on<FetchAccountabilityEntries>((event, emit) async {
      if (event.identification != null) {
        currentIdentification = event.identification;
      }

      _isSearchMode = false;
      loadedPages = 1;
      await updateEntries(emit);
    });

    on<SearchAccountabilityEntries>((event, emit) async {
      currentSearchQuery = event.query.trim();
      currentIdentificationId = event.identificationId;
      currentIdentification = null;
      _isSearchMode = true;
      await _loadFirstPage(emit);
    });

    on<LoadMoreAccountabilityEntries>((event, emit) async {
      if (_isSearchMode) {
        await _loadNextPage(emit);
        return;
      }

      loadedPages += 1;
      await updateEntries(emit);
    });

    on<AddAccountabilityEntry>((event, emit) async {
      await repo.add(event.request);
      _entryCreationVersion++;
      final currentState = state;
      emit(AccountabilityChanged(
        entries: currentState.entries,
        identifications: currentState.identifications,
        searchQuery: currentState.searchQuery,
        identificationId: currentState.identificationId,
        hasMore: currentState.hasMore,
        isLoading: currentState.isLoading,
        entryCreationVersion: _entryCreationVersion,
      ));
      await _refreshEntries(emit);
    });

    on<DeleteAccountabilityEntry>((event, emit) async {
      await repo.delete(event.entry);
      await _refreshEntries(emit);
    });

    on<UpdateAccountabilityEntry>((event, emit) async {
      await repo.update(event.updatedEntry);
      await _refreshEntries(emit);
    });

    on<UpdateAccountabilityIdentification>((event, emit) async {
      await repo.updateIdentification(event.updatedIdentification);
      await _refreshEntries(emit);
    });

    on<DeleteAccountabilityIdentification>((event, emit) async {
      await repo.deleteIdentification(event.identificationId);
      await _refreshEntries(emit);
    });
  }

  Future<void> _refreshEntries(Emitter<AccountabilityState> emit) {
    return _isSearchMode ? _loadFirstPage(emit) : updateEntries(emit);
  }

  Future<void> updateEntries(Emitter<AccountabilityState> emit) async {
    if (currentIdentification != null) {
      final entries =
          await repo.getEntriesByIdentification(currentIdentification!);
      emit(AccountabilityChanged(
        entries: entries,
        identifications: await repo.getIdentifications(),
        identificationId: currentIdentification!.id,
        entryCreationVersion: _entryCreationVersion,
      ));
      return;
    }

    final entries = await repo.getEntries(limit: limit);
    emit(AccountabilityChanged(
      entries: entries,
      identifications: await repo.getIdentifications(),
      hasMore: entries.length >= limit,
      entryCreationVersion: _entryCreationVersion,
    ));
  }

  Future<void> _loadFirstPage(Emitter<AccountabilityState> emit) async {
    final requestVersion = ++_queryVersion;
    final identificationId = currentIdentificationId;
    final previousIdentifications = state.identifications;

    emit(AccountabilityChanged(
      entries: const [],
      identifications: previousIdentifications,
      searchQuery: currentSearchQuery,
      identificationId: identificationId,
      isLoading: true,
      entryCreationVersion: _entryCreationVersion,
    ));

    final entries = await repo.searchEntries(
      limit: pageSize + 1,
      offset: 0,
      searchQuery: currentSearchQuery,
      identificationId: identificationId,
    );
    final identifications = await repo.getIdentifications();

    if (requestVersion != _queryVersion || emit.isDone) {
      return;
    }

    emit(AccountabilityChanged(
      entries: entries.take(pageSize).toList(),
      identifications: identifications,
      searchQuery: currentSearchQuery,
      identificationId: currentIdentificationId,
      hasMore: entries.length > pageSize,
      entryCreationVersion: _entryCreationVersion,
    ));
  }

  Future<void> _loadNextPage(Emitter<AccountabilityState> emit) async {
    final currentState = state;
    if (!currentState.hasMore || currentState.isLoading) {
      return;
    }

    final requestVersion = _queryVersion;
    final identificationId = currentIdentificationId;
    emit(AccountabilityChanged(
      entries: currentState.entries,
      identifications: currentState.identifications,
      searchQuery: currentSearchQuery,
      identificationId: identificationId,
      hasMore: currentState.hasMore,
      isLoading: true,
      entryCreationVersion: _entryCreationVersion,
    ));

    final entries = await repo.searchEntries(
      limit: pageSize + 1,
      offset: currentState.entries.length,
      searchQuery: currentSearchQuery,
      identificationId: identificationId,
    );

    if (requestVersion != _queryVersion || emit.isDone) {
      return;
    }

    final combinedEntries = [
      ...currentState.entries,
      ...entries.take(pageSize)
    ];
    emit(AccountabilityChanged(
      entries: combinedEntries,
      identifications: currentState.identifications,
      searchQuery: currentSearchQuery,
      identificationId: currentIdentificationId,
      hasMore: entries.length > pageSize,
      entryCreationVersion: _entryCreationVersion,
    ));
  }
}
