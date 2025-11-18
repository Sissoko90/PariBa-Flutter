/// Storage Keys Constants
class StorageConstants {
  StorageConstants._();

  // Secure Storage Keys (Sensitive data)
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String personId = 'person_id';
  static const String encryptionKey = 'encryption_key';
  
  // Shared Preferences Keys
  static const String isFirstLaunch = 'is_first_launch';
  static const String isLoggedIn = 'is_logged_in';
  static const String selectedLanguage = 'selected_language';
  static const String themeMode = 'theme_mode';
  static const String biometricEnabled = 'biometric_enabled';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String fcmToken = 'fcm_token';
  
  // Hive Box Names
  static const String userBox = 'user_box';
  static const String groupsBox = 'groups_box';
  static const String contributionsBox = 'contributions_box';
  static const String cacheBox = 'cache_box';
}
