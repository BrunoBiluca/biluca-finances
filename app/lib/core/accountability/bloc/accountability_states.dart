import 'package:biluca_financas/core/accountability/models/accountability_entry.dart';
import 'package:biluca_financas/core/accountability/models/accountability_entry_filter.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:equatable/equatable.dart';

abstract class AccountabilityState extends Equatable {
  final List<AccountabilityEntry> entries;
  final List<AccountabilityIdentification> identifications;
  final String searchQuery;
  final String? identificationId;
  final AccountabilityEntryFilter filter;
  final int? resultCount;
  final bool hasMore;
  final bool isLoading;
  final int entryCreationVersion;
  final String? failureMessage;

  const AccountabilityState({
    required this.entries,
    required this.identifications,
    this.searchQuery = '',
    this.identificationId,
    this.filter = AccountabilityEntryFilter.empty,
    this.resultCount,
    this.hasMore = false,
    this.isLoading = false,
    this.entryCreationVersion = 0,
    this.failureMessage,
  });

  @override
  List<Object?> get props => [
        entries,
        identifications,
        searchQuery,
        identificationId,
        filter,
        resultCount,
        hasMore,
        isLoading,
        entryCreationVersion,
        failureMessage,
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
    super.filter,
    super.resultCount,
    super.hasMore,
    super.isLoading,
    super.entryCreationVersion,
    super.failureMessage,
  });
}
