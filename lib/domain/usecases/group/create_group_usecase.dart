import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/tontine_group.dart';
import '../../repositories/group_repository.dart';

/// Create Group UseCase
class CreateGroupUseCase {
  final GroupRepository repository;

  CreateGroupUseCase(this.repository);

  Future<Either<Failure, TontineGroup>> call({
    required String nom,
    String? description,
    required double montant,
    required String frequency,
    required String rotationMode,
    required int totalTours,
    required String startDate,
    double? latePenaltyAmount,
    int? graceDays,
  }) async {
    return await repository.createGroup(
      nom: nom,
      description: description,
      montant: montant,
      frequency: frequency,
      rotationMode: rotationMode,
      totalTours: totalTours,
      startDate: startDate,
      latePenaltyAmount: latePenaltyAmount,
      graceDays: graceDays,
    );
  }
}
