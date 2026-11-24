import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:equatable/equatable.dart';

abstract class IdentificationCategoriesState extends Equatable {
  final List<AccountabilityIdentification> identifications;
  final bool isLoading;
  final int creationVersion;
  final int updateVersion;
  final int deletionVersion;

  const IdentificationCategoriesState({
    required this.identifications,
    this.isLoading = false,
    this.creationVersion = 0,
    this.updateVersion = 0,
    this.deletionVersion = 0,
  });

  @override
  List<Object?> get props => [
        identifications,
        isLoading,
        creationVersion,
        updateVersion,
        deletionVersion,
      ];
}

class IdentificationCategoriesInitial extends IdentificationCategoriesState {
  const IdentificationCategoriesInitial()
      : super(identifications: const [], isLoading: true);
}

class IdentificationCategoriesChanged extends IdentificationCategoriesState {
  const IdentificationCategoriesChanged({
    required super.identifications,
    super.isLoading,
    super.creationVersion,
    super.updateVersion,
    super.deletionVersion,
  });
}
