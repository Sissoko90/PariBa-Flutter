import 'package:equatable/equatable.dart';

/// Auth Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Login Event
class LoginEvent extends AuthEvent {
  final String identifier;
  final String password;

  const LoginEvent({required this.identifier, required this.password});

  @override
  List<Object?> get props => [identifier, password];
}

/// Register Event
class RegisterEvent extends AuthEvent {
  final String prenom;
  final String nom;
  final String email;
  final String phone;
  final String password;

  const RegisterEvent({
    required this.prenom,
    required this.nom,
    required this.email,
    required this.phone,
    required this.password,
  });

  @override
  List<Object?> get props => [prenom, nom, email, phone, password];
}

/// Logout Event
class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

/// Check Auth Status Event
class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}
