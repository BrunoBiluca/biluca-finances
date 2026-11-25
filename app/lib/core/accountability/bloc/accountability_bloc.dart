import 'package:biluca_financas/core/accountability/bloc/accountability_events.dart';
import 'package:biluca_financas/core/accountability/bloc/accountability_states.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:biluca_financas/core/accountability/services/accountability_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

class AccountabilityBloc
    extends Bloc<AccountabilityEvent, AccountabilityState> {
  final AccountabilityRepo repo;
  final Logger? log;
  static const int pageSize = 100;
  int loadedPages = 1;
  AccountabilityIdentification? currentIdentification;
  String currentSearchQuery = '';
  String? currentIdentificationId;
  int _queryVersion = 0;
  int _entryCreationVersion = 0;
  bool _isSearchMode = false;
  AccountabilityEvent? _lastFailedEvent;

  int get limit => loadedPages * pageSize;

  AccountabilityBloc({required this.repo, this.log})
      : super(const AccountabilityInitial()) {
    on<FetchAccountabilityEntries>(_onFetch);
    on<SearchAccountabilityEntries>(_onSearch);
    on<LoadMoreAccountabilityEntries>(_onLoadMore);
    on<AddAccountabilityEntry>(_onAdd);
    on<DeleteAccountabilityEntry>(_onDelete);
    on<UpdateAccountabilityEntry>(_onUpdate);
    on<RetryAccountability>(_onRetry);
  }

  Future<void> _onFetch(
    FetchAccountabilityEntries event,
    Emitter<AccountabilityState> emit,
  ) async {
    try {
      if (event.identification != null) {
        currentIdentification = event.identification;
      }

      _isSearchMode = false;
      loadedPages = 1;
      await updateEntries(emit);
    } catch (error, stackTrace) {
      _lastFailedEvent = event;
      _emitFailure(
        emit,
        error,
        stackTrace,
        'Não foi possível carregar os lançamentos. Tente novamente.',
      );
    }
  }

  Future<void> _onSearch(
    SearchAccountabilityEntries event,
    Emitter<AccountabilityState> emit,
  ) async {
    try {
      currentSearchQuery = event.query.trim();
      currentIdentificationId = event.identificationId;
      currentIdentification = null;
      _isSearchMode = true;
      await _loadFirstPage(emit);
    } catch (error, stackTrace) {
      _lastFailedEvent = event;
      _emitFailure(
        emit,
        error,
        stackTrace,
        'Não foi possível carregar os lançamentos. Tente novamente.',
      );
    }
  }

  Future<void> _onLoadMore(
    LoadMoreAccountabilityEntries event,
    Emitter<AccountabilityState> emit,
  ) async {
    try {
      if (_isSearchMode) {
        await _loadNextPage(emit);
        return;
      }

      loadedPages += 1;
      await updateEntries(emit);
    } catch (error, stackTrace) {
      _lastFailedEvent = event;
      _emitFailure(
        emit,
        error,
        stackTrace,
        'Não foi possível carregar os lançamentos. Tente novamente.',
      );
    }
  }

  Future<void> _onAdd(
    AddAccountabilityEntry event,
    Emitter<AccountabilityState> emit,
  ) async {
    try {
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
    } catch (error, stackTrace) {
      _lastFailedEvent = event;
      _emitFailure(
        emit,
        error,
        stackTrace,
        'Não foi possível criar o lançamento. Tente novamente.',
      );
    }
  }

  Future<void> _onDelete(
    DeleteAccountabilityEntry event,
    Emitter<AccountabilityState> emit,
  ) async {
    try {
      await repo.delete(event.entry);
      await _refreshEntries(emit);
    } catch (error, stackTrace) {
      _lastFailedEvent = event;
      _emitFailure(
        emit,
        error,
        stackTrace,
        'Não foi possível excluir o lançamento. Tente novamente.',
      );
    }
  }

  Future<void> _onUpdate(
    UpdateAccountabilityEntry event,
    Emitter<AccountabilityState> emit,
  ) async {
    try {
      await repo.update(event.updatedEntry);
      await _refreshEntries(emit);
    } catch (error, stackTrace) {
      _lastFailedEvent = event;
      _emitFailure(
        emit,
        error,
        stackTrace,
        'Não foi possível editar o lançamento. Tente novamente.',
      );
    }
  }

  Future<void> _onRetry(
    RetryAccountability event,
    Emitter<AccountabilityState> emit,
  ) async {
    final failed = _lastFailedEvent;
    _lastFailedEvent = null;
    if (failed == null) return;

    if (failed is FetchAccountabilityEntries) {
      await _onFetch(failed, emit);
    } else if (failed is SearchAccountabilityEntries) {
      await _onSearch(failed, emit);
    } else if (failed is LoadMoreAccountabilityEntries) {
      await _onLoadMore(failed, emit);
    } else if (failed is AddAccountabilityEntry) {
      await _onAdd(failed, emit);
    } else if (failed is DeleteAccountabilityEntry) {
      await _onDelete(failed, emit);
    } else if (failed is UpdateAccountabilityEntry) {
      await _onUpdate(failed, emit);
    }
  }

  void _emitFailure(
    Emitter<AccountabilityState> emit,
    Object error,
    StackTrace stackTrace,
    String message,
  ) {
    log?.severe('Accountability operation failed', error, stackTrace);
    final currentState = state;
    emit(AccountabilityChanged(
      entries: currentState.entries,
      identifications: currentState.identifications,
      searchQuery: currentState.searchQuery,
      identificationId: currentState.identificationId,
      hasMore: currentState.hasMore,
      isLoading: false,
      entryCreationVersion: _entryCreationVersion,
      failureMessage: message,
    ));
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
