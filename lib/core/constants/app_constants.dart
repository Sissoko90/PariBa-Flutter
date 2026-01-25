/// Application Constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'PariBa';
  static const String appVersion = '1.0.0';

  // App Identifiers
  static const String androidPackageName = 'com.example.pariba';
  static const String iosBundleId = 'com.example.pariba';

  // Firebase Configuration
  static const String firebaseProjectId = 'pariba-e71df';
  static const String firebaseStorageBucket =
      'pariba-e71df.firebasestorage.app';
  static const String firebaseMessagingSenderId = '372625413773';

  // Firebase Android
  static const String firebaseAndroidApiKey =
      'AIzaSyAYdkggzCpbfQ2pIdgN6MI9FF58lQg5WJw';
  static const String firebaseAndroidAppId =
      '1:372625413773:android:5f7e6ee1a1426f561134c4';

  // Firebase iOS
  static const String firebaseIosApiKey =
      'AIzaSyBOVImw3JmDTeiSQ6OOk1XBCWhD4smlUFk';
  static const String firebaseIosAppId =
      '1:372625413773:ios:e18f6495135992711134c4';

  // Notification Channel
  static const String notificationChannelId = 'pariba_channel';
  static const String notificationChannelName = 'PariBa Notifications';
  static const String notificationChannelDescription =
      'Notifications de l\'application PariBa';
  static const String notificationSoundAndroid = 'notification';
  static const String notificationSoundIos = 'notification.wav';

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

  // Notification Texts
  static const String notificationEmptyTitle = 'Aucune notification';
  static const String notificationEmptyMessage =
      'Vous n\'avez pas de nouvelles notifications';
  static const String notificationEmptyUnread =
      'Vous n\'avez pas de nouvelles notifications';
  static const String notificationEmptyAll = 'Aucune notification disponible';
  static const String notificationMarkAllRead = 'Tout marquer comme lu';
  static const String notificationRefresh = 'Actualiser';
  static const String notificationFilterAll = 'Toutes';
  static const String notificationFilterUnread = 'Non lues';
  static const String notificationFilterRead = 'Lues';
  static const String notificationRetry = 'Réessayer';

  // Advertisement Texts
  static const String advertisementLabel = 'Publicité';
  static const String advertisementLearnMore = 'En savoir plus';

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
