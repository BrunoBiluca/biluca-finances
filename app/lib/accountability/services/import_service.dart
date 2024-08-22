import 'dart:io';

import 'package:biluca_financas/accountability/models/entry_request.dart';

abstract class AccountabilityImportService {
  late List<AccountabilityEntryRequest> entries;
  Future import(File importedFile);
  Future save();
}
