import 'package:biluca_financas/core/accountability/models/accountability_entry.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:equatable/equatable.dart';

abstract class AccountabilityState extends Equatable {
  final List<AccountabilityEntry> entries;
  final List<AccountabilityIdentification> identifications;
  final String searchQuery;
  final String? identificationId;
  final bool hasMore;
  final bool isLoading;

  const AccountabilityState({
    required this.entries,
    required this.identifications,
    this.searchQuery = '',
    this.identificationId,
    this.hasMore = false,
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [
        entries,
        identifications,
        searchQuery,
        identificationId,
        hasMore,
        isLoading
      ];
}

class AccountabilityInitial extends AccountabilityState {
  const AccountabilityInitial()
      : super(entries: const [], identifications: const []);
}

class AccountabilityChanged extends AccountabilityState {
  const AccountabilityChanged({
    required super.entries,
    required super.identifications,
    super.searchQuery,
    super.identificationId,
    super.hasMore,
    super.isLoading,
  });
}
