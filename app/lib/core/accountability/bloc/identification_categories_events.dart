import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:equatable/equatable.dart';

abstract class IdentificationCategoriesEvent extends Equatable {
  const IdentificationCategoriesEvent();

  @override
  List<Object?> get props => [];
}

class LoadIdentificationCategories extends IdentificationCategoriesEvent {
  const LoadIdentificationCategories();
}

class CreateIdentificationCategory extends IdentificationCategoriesEvent {
  final AccountabilityIdentification identification;

  const CreateIdentificationCategory(this.identification);

  @override
  List<Object?> get props => [identification];
}

class UpdateIdentificationCategory extends IdentificationCategoriesEvent {
  final AccountabilityIdentification identification;

  const UpdateIdentificationCategory(this.identification);

  @override
  List<Object?> get props => [identification];
}

class DeleteIdentificationCategory extends IdentificationCategoriesEvent {
  final String identificationId;

  const DeleteIdentificationCategory(this.identificationId);

  @override
  List<Object?> get props => [identificationId];
}
