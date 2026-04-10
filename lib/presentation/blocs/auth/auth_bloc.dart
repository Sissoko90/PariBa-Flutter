// presentation/blocs/auth/auth_bloc.dart - CORRIGÉ

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/notification_service.dart';
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
  final AuthService authService; // CHANGÉ
  final NotificationService notificationService;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.authRepository,
    required this.authService, // CHANGÉ
    required this.notificationService,
  }) : super(const AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<UploadProfilePhotoEvent>(_onUploadProfilePhoto);
  }

  /// Handle Login
  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    print('🔵 AuthBloc - Début login pour: ${event.identifier}');
    emit(const AuthLoading());
    if (event.otpCode == null || event.otpCode!.isEmpty) {
      emit(const AuthError('Code OTP requis pour la connexion'));
      return;
    }

    final result = await loginUseCase(
      identifier: event.identifier,
      password: event.password,
      otpCode: event.otpCode!,
    );

    if (result.isLeft()) {
      final failure = result.fold((l) => l, (r) => null)!;
      print('❌ AuthBloc - Login échoué: ${failure.message}');
      emit(AuthError(failure.message));
    } else {
      final authResult = result.fold((l) => null, (r) => r)!;
      print('✅ AuthBloc - Login réussi pour: ${authResult.person.email}');

      // Save tokens using AuthService
      await authService.saveAccessToken(authResult.accessToken);
      await authService.savePersonId(authResult.person.id); // AJOUTÉ
      print('💾 AuthBloc - Tokens sauvegardés via AuthService');

      if (authResult.refreshToken != null) {
        await authService.saveRefreshToken(authResult.refreshToken!);
      }

      await authService.saveUserInfo(
        authResult.person.id,
        authResult.person.email ?? authResult.person.phone ?? '',
      );

      // Enregistrer le token FCM au backend
      try {
        await Future.delayed(const Duration(seconds: 1));
        await notificationService.registerTokenToBackend();
        print('✅ AuthBloc - Token FCM enregistré au backend');
      } catch (e) {
        print('⚠️ AuthBloc - Erreur enregistrement token FCM: $e');
      }

      print('🚀 AuthBloc - Émission état Authenticated');
      emit(
        Authenticated(
          person: authResult.person,
          accessToken: authResult.accessToken!,
        ),
      );
      print('✅ AuthBloc - État Authenticated émis avec succès');
    }
  }

  Future<void> _onUploadProfilePhoto(
    UploadProfilePhotoEvent event,
    Emitter<AuthState> emit,
  ) async {
    print('🔵 AuthBloc - Début upload photo');

    // Garder l'état actuel pendant l'upload
    if (state is! Authenticated) return;

    final currentState = state as Authenticated;

    try {
      final result = await authRepository.uploadProfilePhoto(event.file);

      result.fold(
        (failure) {
          print('❌ AuthBloc - Échec upload: ${failure.message}');
          emit(AuthError(failure.message));
          // Remettre l'état précédent
          emit(currentState);
        },
        (updatedPerson) {
          print('✅ AuthBloc - Photo uploadée avec succès');
          emit(
            Authenticated(
              person: updatedPerson,
              accessToken: currentState.accessToken,
            ),
          );
        },
      );
    } catch (e) {
      print('❌ AuthBloc - Erreur: $e');
      emit(AuthError(e.toString()));
      emit(currentState);
    }
  }

  /// Handle Register
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

    if (result.isLeft()) {
      final failure = result.fold((l) => l, (r) => null)!;
      print('❌ AuthBloc - Inscription échouée: ${failure.message}');
      emit(AuthError(failure.message));
    } else {
      final authResult = result.fold((l) => null, (r) => r)!;
      print(
        '✅ AuthBloc - Inscription réussie pour: ${authResult.person.email}',
      );

      // Vérifier si on a un token
      if (authResult.accessToken != null &&
          authResult.accessToken!.isNotEmpty) {
        await authService.saveAccessToken(authResult.accessToken!);
        await authService.savePersonId(authResult.person.id);

        if (authResult.refreshToken != null) {
          await authService.saveRefreshToken(authResult.refreshToken!);
        }

        await authService.saveUserInfo(
          authResult.person.id,
          authResult.person.email ?? authResult.person.phone ?? '',
        );

        emit(
          Authenticated(
            person: authResult.person,
            accessToken: authResult.accessToken!,
          ),
        );
      } else {
        print('ℹ️ Inscription sans token → login requis');

        emit(
          const AuthSuccess('Inscription réussie ! Veuillez vous connecter.'),
        );

        await Future.delayed(const Duration(seconds: 2));
        emit(const Unauthenticated());
      }
    }
  }

  /// Handle Logout
  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final result = await authRepository.logout();

    if (result.isLeft()) {
      final failure = result.fold((l) => l, (r) => null)!;
      emit(AuthError(failure.message));
    } else {
      await authService.clearTokens();
      emit(const Unauthenticated());
    }
  }

  /// Check Auth Status
  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    // Vérifier avec AuthService
    final token = await authService.getAccessToken();

    if (token != null && token.isNotEmpty) {
      try {
        final result = await authRepository.getCurrentUser();

        result.fold(
          (failure) {
            print(
              '❌ AuthBloc - Échec récupération utilisateur: ${failure.message}',
            );
            emit(const Unauthenticated());
          },
          (person) {
            print(
              '✅ AuthBloc - Utilisateur récupéré: ${person.email ?? person.phone ?? person.id}',
            );
            emit(Authenticated(person: person, accessToken: token));
          },
        );
      } catch (e) {
        print('❌ AuthBloc - Erreur vérification auth status: $e');
        emit(const Unauthenticated());
      }
    } else {
      print('❌ AuthBloc - Pas de token trouvé');
      emit(const Unauthenticated());
    }
  }
}
