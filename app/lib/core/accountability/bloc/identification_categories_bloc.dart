import 'package:biluca_financas/core/accountability/bloc/identification_categories_events.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:biluca_financas/core/accountability/bloc/identification_categories_states.dart';
import 'package:biluca_financas/core/accountability/services/accountability_repo.dart';
import 'package:biluca_financas/core/accountability/validators/identification_type_rules.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IdentificationCategoriesBloc
    extends Bloc<IdentificationCategoriesEvent, IdentificationCategoriesState> {
  final AccountabilityRepo repo;

  IdentificationCategoriesBloc({required this.repo})
      : super(const IdentificationCategoriesInitial()) {
    on<LoadIdentificationCategories>((event, emit) async {
      emit(IdentificationCategoriesChanged(
        identifications: state.identifications,
        isLoading: true,
      ));
      await _reload(emit);
    });

    on<CreateIdentificationCategory>((event, emit) async {
      var identification = event.identification;
      final parent = IdentificationTypeRules.parentOf(
        identification.parentId,
        state.identifications,
      );
      if (parent != null) {
        identification = identification.copyWith(type: parent.type);
      }
      await repo.addIdentification(identification);
      await _reload(emit);
    });

    on<UpdateIdentificationCategory>((event, emit) async {
      final current = state.identifications;
      AccountabilityIdentification? previous;
      for (final candidate in current) {
        if (candidate.id == event.identification.id) {
          previous = candidate;
          break;
        }
      }

      var updated = event.identification;
      final parent = IdentificationTypeRules.parentOf(
        updated.parentId,
        current,
      );
      if (parent != null && parent.type != updated.type) {
        updated = updated.copyWith(type: parent.type);
      }

      await repo.updateIdentification(updated);

      final isRoot = updated.parentId == null;
      final changedType = previous != null && previous.type != updated.type;
      if (isRoot && changedType) {
        final children =
            IdentificationTypeRules.childrenOf(updated.id, current);
        for (final child in children) {
          if (child.type != updated.type) {
            await repo.updateIdentification(
              child.copyWith(type: updated.type),
            );
          }
        }
      }

      await _reload(emit);
    });

    on<DeleteIdentificationCategory>((event, emit) async {
      await repo.deleteIdentification(event.identificationId);
      await _reload(emit);
    });
  }

  Future<void> _reload(Emitter<IdentificationCategoriesState> emit) async {
    final identifications = await repo.getIdentifications();
    emit(IdentificationCategoriesChanged(identifications: identifications));
  }
}
