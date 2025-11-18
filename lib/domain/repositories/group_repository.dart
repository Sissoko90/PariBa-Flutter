import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/tontine_group.dart';

/// Group Repository Contract
abstract class GroupRepository {
  /// Get all groups for current user
  Future<Either<Failure, List<TontineGroup>>> getGroups();

  /// Get group by ID
  Future<Either<Failure, TontineGroup>> getGroupById(String groupId);

  /// Create new group
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
  });

  /// Update group
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
  });

  /// Delete group
  Future<Either<Failure, void>> deleteGroup(String groupId);

  /// Leave group
  Future<Either<Failure, void>> leaveGroup(String groupId);

  /// Invite member to group
  Future<Either<Failure, void>> inviteMember({
    required String groupId,
    String? targetPhone,
    String? targetEmail,
  });

  /// Accept invitation
  Future<Either<Failure, void>> acceptInvitation(String invitationId);

  /// Decline invitation
  Future<Either<Failure, void>> declineInvitation(String invitationId);
}
