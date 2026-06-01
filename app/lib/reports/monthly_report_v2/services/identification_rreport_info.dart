import 'package:biluca_financas/accountability/models/identification.dart';

class IdentificationReportInfo {
  final AccountabilityIdentification identification;
  double current;
  double related;
  IdentificationReportInfo({required this.identification, this.current = 0, this.related = 0});
}
