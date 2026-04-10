// core/services/otp_service.dart

import 'package:dartz/dartz.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/errors/failures.dart';

class OtpService {
  final AuthRepository authRepository;

  OtpService({required this.authRepository});

  Future<Either<Failure, void>> sendOtp(
    String target, {
    String? channel,
  }) async {
    return await authRepository.sendOtp(target: target, channel: channel);
  }

  Future<Either<Failure, bool>> verifyOtp(String target, String code) async {
    return await authRepository.verifyOtp(target: target, code: code);
  }
}
