import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:equatable/equatable.dart';

abstract class IdentificationCategoriesState extends Equatable {
  final List<AccountabilityIdentification> identifications;
  final bool isLoading;

  const IdentificationCategoriesState({
    required this.identifications,
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [identifications, isLoading];
}

class IdentificationCategoriesInitial extends IdentificationCategoriesState {
  const IdentificationCategoriesInitial()
      : super(identifications: const [], isLoading: true);
}

class IdentificationCategoriesChanged extends IdentificationCategoriesState {
  const IdentificationCategoriesChanged({
    required super.identifications,
    super.isLoading,
  });
}
