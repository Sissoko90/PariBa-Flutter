// data/mappers/tontine_group_mapper.dart
import '../../domain/entities/tontine_group.dart';
import '../models/tontine_group_model.dart';

class TontineGroupMapper {
  static TontineGroupModel toModel(TontineGroup entity) {
    return TontineGroupModel(
      id: entity.id,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      nom: entity.nom,
      description: entity.description,
      montant: entity.montant,
      frequency: entity.frequency,
      rotationMode: entity.rotationMode,
      totalTours: entity.totalTours,
      startDate: entity.startDate,
      latePenaltyAmount: entity.latePenaltyAmount,
      graceDays: entity.graceDays,
      creatorPersonId: entity.creatorPersonId,
      currentUserRole: entity.currentUserRole,
      status: entity.status,
    );
  }

  static List<TontineGroupModel> toModelList(List<TontineGroup> entities) {
    return entities.map((entity) => toModel(entity)).toList();
  }
}
