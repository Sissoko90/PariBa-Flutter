import 'package:equatable/equatable.dart';

/// Preferences State
class PreferencesState extends Equatable {
  final bool isDarkMode;
  final bool notificationsEnabled;
  final bool emailNotificationsEnabled;
  final bool smsNotificationsEnabled;
  final String language;

  const PreferencesState({
    this.isDarkMode = false,
    this.notificationsEnabled = true,
    this.emailNotificationsEnabled = true,
    this.smsNotificationsEnabled = false,
    this.language = 'fr',
  });

  PreferencesState copyWith({
    bool? isDarkMode,
    bool? notificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? smsNotificationsEnabled,
    String? language,
  }) {
    return PreferencesState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotificationsEnabled:
          emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      smsNotificationsEnabled:
          smsNotificationsEnabled ?? this.smsNotificationsEnabled,
      language: language ?? this.language,
    );
  }

  @override
  List<Object?> get props => [
        isDarkMode,
        notificationsEnabled,
        emailNotificationsEnabled,
        smsNotificationsEnabled,
        language,
      ];
}
