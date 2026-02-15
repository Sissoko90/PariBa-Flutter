import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/security/token_manager.dart';
import '../../domain/entities/tontine_group.dart';
import '../../domain/repositories/group_repository.dart';
import '../datasources/remote/group_remote_datasource.dart';
import '../datasources/remote/invitation_remote_datasource.dart';
import '../models/tontine_group_model.dart';

/// Group Repository Implementation
class GroupRepositoryImpl implements GroupRepository {
  final GroupRemoteDataSource remoteDataSource;
  final InvitationRemoteDataSource invitationDataSource;
  final TokenManager tokenManager;

  GroupRepositoryImpl({
    required this.remoteDataSource,
    required this.invitationDataSource,
    required this.tokenManager,
  });

  @override
  Future<Either<Failure, List<TontineGroup>>> getGroups() async {
    try {
      final personId = await tokenManager.getPersonId();
      if (personId == null) {
        return const Left(UnauthorizedFailure('Non authentifié'));
      }

      final models = await remoteDataSource.getGroups(personId);
      final entities = models.map(_modelToEntity).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TontineGroup>> getGroupById(String groupId) async {
    try {
      final model = await remoteDataSource.getGroupById(groupId);
      return Right(_modelToEntity(model));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TontineGroup>> createGroup({
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
    try {
      final personId = await tokenManager.getPersonId();
      if (personId == null) {
        return const Left(UnauthorizedFailure('Non authentifié'));
      }

      final model = await remoteDataSource.createGroup({
        'nom': nom,
        'description': description,
        'montant': montant,
        'frequency': frequency,
        'rotationMode': rotationMode,
        'totalTours': totalTours,
        'startDate': startDate,
        'latePenaltyAmount': latePenaltyAmount,
        'graceDays': graceDays,
        'creatorPersonId': personId,
      });

      return Right(_modelToEntity(model));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TontineGroup>> updateGroup({
    required String groupId,
    String? nom,
    String? description,
    double? montant,
    String? frequency,
    String? rotationMode,
    int? totalTours,
    String? startDate,
    double? latePenaltyAmount,
    int? graceDays,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (nom != null) data['nom'] = nom;
      if (description != null) data['description'] = description;
      if (montant != null) data['montant'] = montant;
      if (frequency != null) data['frequency'] = frequency;
      if (rotationMode != null) data['rotationMode'] = rotationMode;
      if (totalTours != null) data['totalTours'] = totalTours;
      if (startDate != null) data['startDate'] = startDate;
      if (latePenaltyAmount != null)
        data['latePenaltyAmount'] = latePenaltyAmount;
      if (graceDays != null) data['graceDays'] = graceDays;

      final model = await remoteDataSource.updateGroup(groupId, data);
      return Right(_modelToEntity(model));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteGroup(String groupId) async {
    try {
      await remoteDataSource.deleteGroup(groupId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> leaveGroup(String groupId) async {
    try {
      await remoteDataSource.leaveGroup(groupId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> inviteMember({
    required String groupId,
    String? targetPhone,
    String? targetEmail,
  }) async {
    try {
      final phone = targetPhone ?? targetEmail;
      if (phone == null) {
        return const Left(ValidationFailure('Téléphone ou email requis'));
      }

      await invitationDataSource.inviteMember(groupId, phone, null);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> acceptInvitation(String invitationId) async {
    try {
      await invitationDataSource.acceptInvitation(invitationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> declineInvitation(String invitationId) async {
    // Le backend n'a pas d'endpoint pour décliner, on peut juste ignorer
    return const Right(null);
  }

  // Helper method to convert TontineGroupModel to TontineGroup entity
  TontineGroup _modelToEntity(TontineGroupModel model) {
    return TontineGroup(
      id: model.id,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      nom: model.nom,
      description: model.description,
      montant: model.montant,
      frequency: model.frequency,
      rotationMode: model.rotationMode,
      totalTours: model.totalTours,
      startDate: model.startDate,
      latePenaltyAmount: model.latePenaltyAmount,
      graceDays: model.graceDays,
      creatorPersonId: model.creatorPersonId,
      currentUserRole:
          model.currentUserRole, //  AJOUTÉ - pour ne pas perdre le rôle !
      status: model.status ?? 'active',
    );
  }
}
