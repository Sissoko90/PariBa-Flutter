import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/security/token_manager.dart';
import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../domain/usecases/auth/register_usecase.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Auth BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final AuthRepository authRepository;
  final TokenManager tokenManager;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.authRepository,
    required this.tokenManager,
  }) : super(const AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  /// Handle Login
  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    print('🔵 AuthBloc - Début login pour: ${event.identifier}');
    emit(const AuthLoading());

    final result = await loginUseCase(
      identifier: event.identifier,
      password: event.password,
    );

    // Utiliser if/else au lieu de fold pour gérer correctement async
    if (result.isLeft()) {
      final failure = result.fold((l) => l, (r) => null)!;
      print('❌ AuthBloc - Login échoué: ${failure.message}');
      emit(AuthError(failure.message));
    } else {
      final authResult = result.fold((l) => null, (r) => r)!;
      print('✅ AuthBloc - Login réussi pour: ${authResult.person.email}');

      // Save tokens
      await tokenManager.saveAccessToken(authResult.accessToken);
      print('💾 AuthBloc - Access token sauvegardé');

      if (authResult.refreshToken != null) {
        await tokenManager.saveRefreshToken(authResult.refreshToken!);
      }

      await tokenManager.savePersonId(authResult.person.id);
      print('💾 AuthBloc - Person ID sauvegardé: ${authResult.person.id}');

      print('🚀 AuthBloc - Émission état Authenticated');
      emit(
        Authenticated(
          person: authResult.person,
          accessToken: authResult.accessToken,
        ),
      );
      print('✅ AuthBloc - État Authenticated émis avec succès');
    }
  }

  /// Handle Register
  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    print('🔵 AuthBloc - Début inscription pour: ${event.email}');
    emit(const AuthLoading());

    final result = await registerUseCase(
      prenom: event.prenom,
      nom: event.nom,
      email: event.email,
      phone: event.phone,
      password: event.password,
    );

    // Utiliser if/else au lieu de fold pour gérer correctement async
    if (result.isLeft()) {
      final failure = result.fold((l) => l, (r) => null)!;
      print('❌ AuthBloc - Inscription échouée: ${failure.message}');
      emit(AuthError(failure.message));
    } else {
      final authResult = result.fold((l) => null, (r) => r)!;
      print(
        '✅ AuthBloc - Inscription réussie pour: ${authResult.person.email}',
      );

      // Save tokens
      await tokenManager.saveAccessToken(authResult.accessToken);
      print('💾 AuthBloc - Access token sauvegardé');

      if (authResult.refreshToken != null) {
        await tokenManager.saveRefreshToken(authResult.refreshToken!);
      }

      await tokenManager.savePersonId(authResult.person.id);
      print('💾 AuthBloc - Person ID sauvegardé: ${authResult.person.id}');

      print('🚀 AuthBloc - Émission état Authenticated');
      emit(
        Authenticated(
          person: authResult.person,
          accessToken: authResult.accessToken,
        ),
      );
      print('✅ AuthBloc - État Authenticated émis avec succès');
    }
  }

  /// Handle Logout
  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final result = await authRepository.logout();

    result.fold((failure) => emit(AuthError(failure.message)), (_) async {
      await tokenManager.clearTokens();
      emit(const Unauthenticated());
    });
  }

  /// Check Auth Status
  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final isAuth = await authRepository.isAuthenticated();

    if (isAuth) {
      final result = await authRepository.getCurrentUser();
      await result.fold((failure) async => emit(const Unauthenticated()), (
        person,
      ) async {
        final token = await tokenManager.getAccessToken();
        if (!emit.isDone) {
          emit(Authenticated(person: person, accessToken: token ?? ''));
        }
      });
    } else {
      emit(const Unauthenticated());
    }
  }
}
