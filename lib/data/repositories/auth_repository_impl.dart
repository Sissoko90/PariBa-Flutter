import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/security/token_manager.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/entities/person.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../models/person_model.dart';

/// Auth Repository Implementation
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenManager tokenManager;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenManager,
  });

  @override
  Future<Either<Failure, AuthResult>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.login(email, password);
      
      final person = _personModelToEntity(
        PersonModel.fromJson(result['person']),
      );

      final authResult = AuthResult(
        accessToken: result['accessToken'],
        refreshToken: result['refreshToken'],
        person: person,
      );

      return Right(authResult);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> register({
    required String prenom,
    required String nom,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.register({
        'prenom': prenom,
        'nom': nom,
        'email': email,
        'phone': phone,
        'password': password,
      });

      final person = _personModelToEntity(
        PersonModel.fromJson(result['person']),
      );

      final authResult = AuthResult(
        accessToken: result['accessToken'],
        refreshToken: result['refreshToken'],
        person: person,
      );

      return Right(authResult);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendOtp({
    required String target,
    required String type,
  }) async {
    // TODO: Implement OTP sending
    return const Right(null);
  }

  @override
  Future<Either<Failure, bool>> verifyOtp({
    required String target,
    required String code,
  }) async {
    // TODO: Implement OTP verification
    return const Right(true);
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final refreshToken = await tokenManager.getRefreshToken();
      if (refreshToken != null) {
        await remoteDataSource.logout(refreshToken);
      }
      await tokenManager.clearTokens();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Person>> getCurrentUser() async {
    try {
      final isAuth = await tokenManager.isAuthenticated();
      if (!isAuth) {
        return const Left(UnauthorizedFailure('Non authentifié'));
      }

      final personModel = await remoteDataSource.getCurrentUser();
      return Right(_personModelToEntity(personModel));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> refreshAccessToken(String refreshToken) async {
    try {
      final tokens = await remoteDataSource.refreshToken(refreshToken);
      final newAccessToken = tokens['accessToken'] as String;
      final newRefreshToken = tokens['refreshToken'] as String;
      
      await tokenManager.saveAccessToken(newAccessToken);
      await tokenManager.saveRefreshToken(newRefreshToken);
      
      return Right(newAccessToken);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return await tokenManager.isAuthenticated();
  }

  // Helper method to convert PersonModel to Person entity
  Person _personModelToEntity(PersonModel model) {
    return Person(
      id: model.id,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      prenom: model.prenom,
      nom: model.nom,
      email: model.email,
      phone: model.phone,
      photo: model.photo,
      role: model.role,
    );
  }
}
