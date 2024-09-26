import 'dart:io';

import 'package:biluca_financas/accountability/models/entry.dart';
import 'package:biluca_financas/accountability/models/entry_request.dart';

abstract class AccountabilityImportService {
  List<AccountabilityEntryRequest> entries = [];
  List<AccountabilityEntry> duplicatedEntries = [];
  Future import(File importedFile);
  Future save();
  void cancelDuplication(AccountabilityEntry entry);
}
