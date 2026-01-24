import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/auth_result.dart';
import '../entities/person.dart';

/// Auth Repository Contract
abstract class AuthRepository {
  /// Login with email and password
  Future<Either<Failure, AuthResult>> login({
    required String identifier,
    required String password,
  });

  /// Register new user
  Future<Either<Failure, AuthResult>> register({
    required String prenom,
    required String nom,
    required String email,
    required String phone,
    required String password,
  });

  /// Send OTP code
  Future<Either<Failure, void>> sendOtp({
    required String target,
    required String type, // phone or email
  });

  /// Verify OTP code
  Future<Either<Failure, bool>> verifyOtp({
    required String target,
    required String code,
  });

  /// Logout
  Future<Either<Failure, void>> logout();

  /// Get current user
  Future<Either<Failure, Person>> getCurrentUser();

  /// Refresh access token
  Future<Either<Failure, String>> refreshAccessToken(String refreshToken);

  /// Check if user is authenticated
  Future<bool> isAuthenticated();
}
