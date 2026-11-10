import 'package:biluca_financas/core/accountability/models/accountability_entry.dart';
import 'package:biluca_financas/core/accountability/models/accountability_entry_request.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:equatable/equatable.dart';

abstract class AccountabilityEvent extends Equatable {
  const AccountabilityEvent();
}

class FetchAccountabilityEntries extends AccountabilityEvent {
  final AccountabilityIdentification? identification;
  const FetchAccountabilityEntries({this.identification});

  @override
  List<Object?> get props => [identification?.id];
}

class SearchAccountabilityEntries extends AccountabilityEvent {
  final String query;
  final String? identificationId;

  const SearchAccountabilityEntries({
    required this.query,
    required this.identificationId,
  });

  @override
  List<Object?> get props => [query, identificationId];
}

class LoadMoreAccountabilityEntries extends AccountabilityEvent {
  @override
  List<Object?> get props => [];
}

class AddAccountabilityEntry extends AccountabilityEvent {
  final AccountabilityEntryRequest request;
  const AddAccountabilityEntry(this.request);

  @override
  List<Object?> get props => [request];
}

class DeleteAccountabilityEntry extends AccountabilityEvent {
  final AccountabilityEntry entry;
  const DeleteAccountabilityEntry(this.entry);

  @override
  List<Object?> get props => [entry];
}

class UpdateAccountabilityEntry extends AccountabilityEvent {
  final AccountabilityEntry updatedEntry;
  const UpdateAccountabilityEntry(this.updatedEntry);

  @override
  List<Object?> get props => [updatedEntry];
}
