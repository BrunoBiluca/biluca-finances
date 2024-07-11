import 'package:biluca_financas/accountability/models/entry.dart';
import 'package:biluca_financas/accountability/models/entry_request.dart';
import 'package:biluca_financas/accountability/models/identification.dart';
import 'package:equatable/equatable.dart';

abstract class AccountabilityEvent extends Equatable {
  const AccountabilityEvent();
}

class FetchAccountabilityEntries extends AccountabilityEvent {
  @override
  List<Object> get props => [];
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

class DeleteAccountabilityIdentification extends AccountabilityEvent {
  final String identificationId;
  const DeleteAccountabilityIdentification(this.identificationId);

  @override
  List<Object?> get props => [identificationId];
}

class UpdateAccountabilityIdentification extends AccountabilityEvent {
  final AccountabilityIdentification updatedIdentification;
  const UpdateAccountabilityIdentification(this.updatedIdentification);

  @override
  List<Object?> get props => [updatedIdentification];
}