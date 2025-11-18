import 'package:shared_preferences/shared_preferences.dart';

/// Preferences Service - Gestion des préférences utilisateur
class PreferencesService {
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyEmailNotifications = 'email_notifications';
  static const String _keySmsNotifications = 'sms_notifications';
  static const String _keyLanguage = 'language';

  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  // Theme Mode
  bool get isDarkMode => _prefs.getBool(_keyThemeMode) ?? false;

  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool(_keyThemeMode, value);
  }

  // Notifications
  bool get notificationsEnabled =>
      _prefs.getBool(_keyNotificationsEnabled) ?? true;

  Future<void> setNotificationsEnabled(bool value) async {
    await _prefs.setBool(_keyNotificationsEnabled, value);
  }

  bool get emailNotificationsEnabled =>
      _prefs.getBool(_keyEmailNotifications) ?? true;

  Future<void> setEmailNotificationsEnabled(bool value) async {
    await _prefs.setBool(_keyEmailNotifications, value);
  }

  bool get smsNotificationsEnabled =>
      _prefs.getBool(_keySmsNotifications) ?? false;

  Future<void> setSmsNotificationsEnabled(bool value) async {
    await _prefs.setBool(_keySmsNotifications, value);
  }

  // Language
  String get language => _prefs.getString(_keyLanguage) ?? 'fr';

  Future<void> setLanguage(String value) async {
    await _prefs.setString(_keyLanguage, value);
  }

  // Clear all preferences
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
