import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../data/models/group_share_link_model.dart';
import '../entities/join_request.dart';

abstract class JoinRequestRepository {
  Future<Either<Failure, JoinRequest>> createJoinRequest({
    required String groupId,
    String? message,
  });

  Future<Either<Failure, JoinRequest>> approveJoinRequest({
    required String requestId,
    String? note,
  });

  Future<Either<Failure, JoinRequest>> rejectJoinRequest({
    required String requestId,
    String? note,
  });

  Future<Either<Failure, void>> cancelJoinRequest(String requestId);

  Future<Either<Failure, List<JoinRequest>>> getGroupJoinRequests(
    String groupId,
  );

  Future<Either<Failure, List<JoinRequest>>> getMyJoinRequests();

  Future<Either<Failure, int>> getPendingJoinRequestsCount(String groupId);

  Future<Either<Failure, GroupShareLinkModel>> generateShareLink(
    String groupId,
  );
}
