import 'package:equatable/equatable.dart';
import '../../../domain/entities/person.dart';

/// Auth States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial State
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading State
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated State
class Authenticated extends AuthState {
  final Person person;
  final String accessToken;

  const Authenticated({
    required this.person,
    required this.accessToken,
  });

  @override
  List<Object?> get props => [person, accessToken];
}

/// Unauthenticated State
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Auth Error State
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
