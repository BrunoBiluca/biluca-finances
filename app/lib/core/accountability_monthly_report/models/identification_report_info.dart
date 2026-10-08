import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';

class IdentificationReportInfo {
  final AccountabilityIdentification identification;
  double current;
  double related;
  double avgRecentMonts;
  double participationInTotal;

  IdentificationReportInfo({
    required this.identification,
    this.current = 0,
    this.related = 0,
    this.avgRecentMonts = 0,
    this.participationInTotal = 0,
  });
}
