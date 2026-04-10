// lib/data/repositories/subscription_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/remote/subscription_remote_datasource.dart';
import '../models/subscription_plan_model.dart';
import '../models/subscription_request_model.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRemoteDataSource remoteDataSource;

  SubscriptionRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<SubscriptionPlanModel>>> getPlans() async {
    try {
      final plans = await remoteDataSource.getPlans();
      return Right(plans);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubscriptionPlanModel?>> getMySubscription() async {
    try {
      final subscription = await remoteDataSource.getMySubscription();
      return Right(subscription);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubscriptionRequestModel>> requestSubscription({
    required String planId,
    String billingPeriod = 'monthly',
    String? notes,
  }) async {
    try {
      final request = await remoteDataSource.requestSubscription(
        planId: planId,
        billingPeriod: billingPeriod,
        notes: notes,
      );
      return Right(request);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SubscriptionRequestModel>>>
  getMyRequests() async {
    try {
      final requests = await remoteDataSource.getMyRequests();
      return Right(requests);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelRequest(String requestId) async {
    try {
      await remoteDataSource.cancelRequest(requestId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkFeatureAccess(String feature) async {
    try {
      final hasAccess = await remoteDataSource.checkFeatureAccess(feature);
      return Right(hasAccess);
    } catch (e) {
      return const Right(false);
    }
  }
}
