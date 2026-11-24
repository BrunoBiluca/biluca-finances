import 'dart:io';

import 'package:biluca_financas/core/accountability/models/accountability_entry_request.dart';

abstract interface class AccountabilityIdentificationPredictionService {
  Future<List<AccountabilityEntryRequest>> predict({
    List<AccountabilityEntryRequest>? entries,
    File? importedFile,
  });
}
