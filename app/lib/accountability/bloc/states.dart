import 'package:biluca_financas/accountability/models/entry.dart';
import 'package:biluca_financas/accountability/models/identification.dart';
import 'package:equatable/equatable.dart';

abstract class AccountabilityState extends Equatable {
  final List<AccountabilityEntry> entries;
  final List<AccountabilityIdentification> identifications;

  const AccountabilityState({required this.entries, required this.identifications});

  @override
  List<Object> get props => [entries, identifications];
}

class AccountabilityInitial extends AccountabilityState {
  const AccountabilityInitial() : super(entries: const [], identifications: const []);
}

class AccountabilityChanged extends AccountabilityState {
  const AccountabilityChanged({required super.entries, required super.identifications});
}
