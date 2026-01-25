import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../data/datasources/remote/notification_remote_datasource.dart';

/// Use case pour enregistrer le token FCM au backend
class RegisterFcmTokenUseCase {
  final NotificationRemoteDataSource _notificationDataSource;

  RegisterFcmTokenUseCase(this._notificationDataSource);

  Future<Either<Failure, void>> call(String token) async {
    try {
      await _notificationDataSource.registerFcmToken(token);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
