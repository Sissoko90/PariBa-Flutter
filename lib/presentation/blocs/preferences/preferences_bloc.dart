import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/preferences_service.dart';
import 'preferences_event.dart';
import 'preferences_state.dart';

/// Preferences BLoC
class PreferencesBloc extends Bloc<PreferencesEvent, PreferencesState> {
  final PreferencesService preferencesService;

  PreferencesBloc({required this.preferencesService})
      : super(const PreferencesState()) {
    on<LoadPreferencesEvent>(_onLoadPreferences);
    on<ToggleDarkModeEvent>(_onToggleDarkMode);
    on<ToggleNotificationsEvent>(_onToggleNotifications);
    on<ToggleEmailNotificationsEvent>(_onToggleEmailNotifications);
    on<ToggleSmsNotificationsEvent>(_onToggleSmsNotifications);
    on<ChangeLanguageEvent>(_onChangeLanguage);
  }

  Future<void> _onLoadPreferences(
    LoadPreferencesEvent event,
    Emitter<PreferencesState> emit,
  ) async {
    emit(state.copyWith(
      isDarkMode: preferencesService.isDarkMode,
      notificationsEnabled: preferencesService.notificationsEnabled,
      emailNotificationsEnabled: preferencesService.emailNotificationsEnabled,
      smsNotificationsEnabled: preferencesService.smsNotificationsEnabled,
      language: preferencesService.language,
    ));
  }

  Future<void> _onToggleDarkMode(
    ToggleDarkModeEvent event,
    Emitter<PreferencesState> emit,
  ) async {
    await preferencesService.setDarkMode(event.isDark);
    emit(state.copyWith(isDarkMode: event.isDark));
  }

  Future<void> _onToggleNotifications(
    ToggleNotificationsEvent event,
    Emitter<PreferencesState> emit,
  ) async {
    await preferencesService.setNotificationsEnabled(event.enabled);
    emit(state.copyWith(notificationsEnabled: event.enabled));
  }

  Future<void> _onToggleEmailNotifications(
    ToggleEmailNotificationsEvent event,
    Emitter<PreferencesState> emit,
  ) async {
    await preferencesService.setEmailNotificationsEnabled(event.enabled);
    emit(state.copyWith(emailNotificationsEnabled: event.enabled));
  }

  Future<void> _onToggleSmsNotifications(
    ToggleSmsNotificationsEvent event,
    Emitter<PreferencesState> emit,
  ) async {
    await preferencesService.setSmsNotificationsEnabled(event.enabled);
    emit(state.copyWith(smsNotificationsEnabled: event.enabled));
  }

  Future<void> _onChangeLanguage(
    ChangeLanguageEvent event,
    Emitter<PreferencesState> emit,
  ) async {
    await preferencesService.setLanguage(event.language);
    emit(state.copyWith(language: event.language));
  }
}
