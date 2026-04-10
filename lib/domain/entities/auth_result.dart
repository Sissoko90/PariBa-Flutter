import 'package:equatable/equatable.dart';
import 'person.dart';

/// Auth Result Entity - Résultat d'authentification
class AuthResult extends Equatable {
  final String? accessToken;
  final String? refreshToken;
  final Person person;

  const AuthResult({this.accessToken, this.refreshToken, required this.person});

  @override
  List<Object?> get props => [accessToken, refreshToken, person];
}
