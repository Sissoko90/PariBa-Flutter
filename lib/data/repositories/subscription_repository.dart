import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../models/subscription_model.dart';
import '../datasources/remote/subscription_remote_datasource.dart';

class SubscriptionRepository {
  final SubscriptionRemoteDataSource remote;

  SubscriptionRepository(this.remote);

  Future<Either<Failure, SubscriptionModel?>> getActiveSubscription() async {
    try {
      final data = await remote.getMySubscription();

      if (data == null) return const Right(null);

      return Right(SubscriptionModel.fromJson(data));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> subscribe(String planId) async {
    try {
      await remote.subscribe(planId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
