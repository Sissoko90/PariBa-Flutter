import 'package:equatable/equatable.dart';

/// Preferences Events
abstract class PreferencesEvent extends Equatable {
  const PreferencesEvent();

  @override
  List<Object?> get props => [];
}

/// Load Preferences
class LoadPreferencesEvent extends PreferencesEvent {
  const LoadPreferencesEvent();
}

/// Toggle Dark Mode
class ToggleDarkModeEvent extends PreferencesEvent {
  final bool isDark;

  const ToggleDarkModeEvent(this.isDark);

  @override
  List<Object?> get props => [isDark];
}

/// Toggle Notifications
class ToggleNotificationsEvent extends PreferencesEvent {
  final bool enabled;

  const ToggleNotificationsEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Toggle Email Notifications
class ToggleEmailNotificationsEvent extends PreferencesEvent {
  final bool enabled;

  const ToggleEmailNotificationsEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Toggle SMS Notifications
class ToggleSmsNotificationsEvent extends PreferencesEvent {
  final bool enabled;

  const ToggleSmsNotificationsEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Change Language
class ChangeLanguageEvent extends PreferencesEvent {
  final String language;

  const ChangeLanguageEvent(this.language);

  @override
  List<Object?> get props => [language];
}
