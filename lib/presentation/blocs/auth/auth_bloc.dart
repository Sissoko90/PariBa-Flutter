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

    final result = await loginUseCase(
      identifier: event.identifier,
      password: event.password,
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
        authResult.person.email,
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

    if (result.isLeft()) {
      final failure = result.fold((l) => l, (r) => null)!;
      print('❌ AuthBloc - Inscription échouée: ${failure.message}');
      emit(AuthError(failure.message));
    } else {
      final authResult = result.fold((l) => null, (r) => r)!;
      print(
        '✅ AuthBloc - Inscription réussie pour: ${authResult.person.email}',
      );

      // Save tokens using AuthService
      await authService.saveAccessToken(authResult.accessToken);
      await authService.savePersonId(authResult.person.id); // AJOUTÉ
      print('💾 AuthBloc - Tokens sauvegardés via AuthService');

      if (authResult.refreshToken != null) {
        await authService.saveRefreshToken(authResult.refreshToken!);
      }

      await authService.saveUserInfo(
        authResult.person.id,
        authResult.person.email,
      );

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

    if (result.isLeft()) {
      final failure = result.fold((l) => l, (r) => null)!;
      emit(AuthError(failure.message));
    } else {
      await authService.clearTokens();
      emit(const Unauthenticated());
    }
  }

  Future<void> _onUploadProfilePhoto(
    UploadProfilePhotoEvent event,
    Emitter<AuthState> emit,
  ) async {
    print('🔵 AuthBloc - Début upload photo de profil');

    try {
      // Appel au repository pour uploader la photo
      final result = await authRepository.uploadProfilePhoto(event.file);

      result.fold(
        (failure) {
          print('❌ AuthBloc - Échec upload photo: ${failure.message}');
          emit(AuthError(failure.message));
        },
        (updatedPerson) {
          print('✅ AuthBloc - Photo uploadée avec succès');

          // Mettre à jour l'état avec la nouvelle personne
          if (state is Authenticated) {
            final currentState = state as Authenticated;
            emit(
              Authenticated(
                person: updatedPerson,
                accessToken: currentState.accessToken,
              ),
            );
          }
        },
      );
    } catch (e) {
      print('❌ AuthBloc - Erreur upload photo: $e');
      emit(AuthError('Erreur lors de l\'upload: ${e.toString()}'));
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
            print('✅ AuthBloc - Utilisateur récupéré: ${person.email}');
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
