import 'accountability_identification.dart';

abstract class AccountabilityTableEntry {
  String get description;
  double get value;
  set value(double value);
  AccountabilityIdentification? get identification;
  set identification(AccountabilityIdentification? value);
  DateTime get createdAt;
  DateTime? get insertedAt;
  String? get descriptionAlt;
  set descriptionAlt(String? value);
}
