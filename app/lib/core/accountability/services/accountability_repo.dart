import 'package:biluca_financas/core/accountability/models/accountability_entry.dart';
import 'package:biluca_financas/core/accountability/models/accountability_entry_request.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';

abstract class AccountabilityRepo {
  Future<List<AccountabilityEntry>> getEntries({int limit = 10, int offset = 0});
  Future<List<AccountabilityEntry>> getEntriesByIdentification(AccountabilityIdentification identification);

  Future<AccountabilityEntry> getById(int id);
  Future<AccountabilityEntry?> exists(AccountabilityEntryRequest req);
  Future<AccountabilityEntry> add(AccountabilityEntryRequest req);
  Future<void> delete(AccountabilityEntry entry);
  Future<AccountabilityEntry> update(AccountabilityEntry entry);

  Future<List<AccountabilityIdentification>> getIdentifications();
  Future<String?> addOrGetIdentification(AccountabilityIdentification? identification);
  Future<AccountabilityIdentification?> getIdentification(String identificationId);
  Future<AccountabilityIdentification> addIdentification(AccountabilityIdentification identification);
  Future<void> updateIdentification(AccountabilityIdentification updatedIdentification);
  Future<void> deleteIdentification(String id);
}
