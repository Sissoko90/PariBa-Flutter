/// Application Constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'PariBa';
  static const String appVersion = '1.0.0';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Currency
  static const String currency = 'FCFA';
  static const String currencySymbol = 'FCFA';
  
  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String timeFormat = 'HH:mm';
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;
  static const int otpLength = 6;
  static const int otpExpiryMinutes = 5;
  
  // Phone
  static const String defaultCountryCode = '+223';
  static const String phonePattern = r'^\+223[0-9]{8}$';
  
  // Email
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  
  // Image
  static const int maxImageSizeMB = 5;
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png'];
  
  // Cache
  static const Duration cacheExpiry = Duration(hours: 24);
  
  // Notification
  static const String fcmTopic = 'pariba_notifications';
}
