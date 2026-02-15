import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/join_request.dart';
import '../../domain/repositories/join_request_repository.dart';
import '../datasources/remote/join_request_remote_datasource.dart';
import '../models/group_share_link_model.dart';

class JoinRequestRepositoryImpl implements JoinRequestRepository {
  final JoinRequestRemoteDataSource remoteDataSource;

  JoinRequestRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, JoinRequest>> createJoinRequest({
    required String groupId,
    String? message,
  }) async {
    try {
      final result = await remoteDataSource.createJoinRequest(
        groupId: groupId,
        message: message,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, JoinRequest>> approveJoinRequest({
    required String requestId,
    String? note,
  }) async {
    try {
      final result = await remoteDataSource.reviewJoinRequest(
        requestId: requestId,
        action: 'APPROVE',
        note: note,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, JoinRequest>> rejectJoinRequest({
    required String requestId,
    String? note,
  }) async {
    try {
      final result = await remoteDataSource.reviewJoinRequest(
        requestId: requestId,
        action: 'REJECT',
        note: note,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelJoinRequest(String requestId) async {
    try {
      await remoteDataSource.cancelJoinRequest(requestId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<JoinRequest>>> getGroupJoinRequests(
    String groupId,
  ) async {
    try {
      final result = await remoteDataSource.getGroupJoinRequests(groupId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<JoinRequest>>> getMyJoinRequests() async {
    try {
      final result = await remoteDataSource.getMyJoinRequests();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getPendingJoinRequestsCount(
    String groupId,
  ) async {
    try {
      final result =
          await remoteDataSource.getPendingJoinRequestsCount(groupId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GroupShareLinkModel>> generateShareLink(
    String groupId,
  ) async {
    try {
      final result = await remoteDataSource.generateShareLink(groupId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
