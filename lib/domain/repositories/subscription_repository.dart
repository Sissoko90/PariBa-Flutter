// lib/domain/repositories/subscription_repository.dart

import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../data/models/subscription_plan_model.dart';
import '../../data/models/subscription_request_model.dart';

abstract class SubscriptionRepository {
  Future<Either<Failure, List<SubscriptionPlanModel>>> getPlans();
  Future<Either<Failure, SubscriptionPlanModel?>> getMySubscription();
  Future<Either<Failure, SubscriptionRequestModel>> requestSubscription({
    required String planId,
    String billingPeriod,
    String? notes,
  });
  Future<Either<Failure, List<SubscriptionRequestModel>>> getMyRequests();
  Future<Either<Failure, void>> cancelRequest(String requestId);
  Future<Either<Failure, bool>> checkFeatureAccess(String feature);
}
