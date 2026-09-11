import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';

class MonthlyIdentificationsSummary {
  final AccountabilityIdentification identification;
  final Map<String, double> monthTotal;
  MonthlyIdentificationsSummary({
    required this.identification,
    required this.monthTotal,
  });
}
