import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/auth_result.dart';
import '../../repositories/auth_repository.dart';

/// Register UseCase
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, AuthResult>> call({
    required String prenom,
    required String nom,
    required String email,
    required String phone,
    required String password,
  }) async {
    return await repository.register(
      prenom: prenom,
      nom: nom,
      email: email,
      phone: phone,
      password: password,
    );
  }
}
