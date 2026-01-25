/// API Constants for PariBa Application
class ApiConstants {
  ApiConstants._();

  // Base URL - Backend Spring Boot sur port 8082
  /// Base URL for API
  /// Pour Android Emulator, utilisez 10.0.2.2 au lieu de localhost
  /// Pour iOS Simulator, utilisez localhost ou votre IP
  static const String baseUrl = 'http://192.168.100.99:8085/api/v1';

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/password/forgot';
  static const String resetPassword = '/auth/password/reset';
  static const String changePassword = '/auth/password/change';
  static const String sendOtp = '/auth/otp/send';
  static const String verifyOtp = '/auth/otp/verify';
  static const String validateToken = '/auth/validate';

  // Groups Endpoints
  static const String groups = '/groups';
  static const String myGroups = '/groups/my-groups';
  static const String createdGroups = '/groups/created-by-me';
  static String groupById(String id) => '/groups/$id';
  static String leaveGroup(String id) => '/groups/$id/leave';

  // Memberships Endpoints
  static const String memberships = '/memberships';
  static const String myMemberships = '/memberships/my-memberships';
  static String groupMembers(String groupId) => '/memberships/group/$groupId';
  static String memberByGroupAndPerson(String groupId, String personId) =>
      '/memberships/group/$groupId/person/$personId';
  static const String updateMemberRole = '/memberships/role';
  static String promoteMember(String groupId, String personId) =>
      '/memberships/group/$groupId/person/$personId/promote';
  static String demoteMember(String groupId, String personId) =>
      '/memberships/group/$groupId/person/$personId/demote';
  static String removeMember(String groupId, String personId) =>
      '/memberships/group/$groupId/member/$personId';

  // Invitations Endpoints
  static const String invitations = '/invitations';
  static const String acceptInvitation = '/invitations/accept';
  static String groupInvitations(String groupId) =>
      '/invitations/group/$groupId';

  // Payments Endpoints
  static const String payments = '/payments';
  static String paymentById(String id) => '/payments/$id';
  static String paymentsByContribution(String contributionId) =>
      '/payments/contribution/$contributionId';
  static String paymentsByPerson(String personId) =>
      '/payments/person/$personId';
  static String verifyPayment(String id) => '/payments/$id/verify';

  // Contributions Endpoints
  static const String contributions = '/contributions';
  static String contributionById(String id) => '/contributions/$id';
  static String contributionsByTour(String tourId) =>
      '/contributions/tour/$tourId';
  static String contributionsByMember(String personId) =>
      '/contributions/member/$personId';
  static String pendingContributions(String groupId) =>
      '/contributions/group/$groupId/pending';

  // Notifications Endpoints
  static const String notifications = '/notifications';
  static const String unreadNotifications = '/notifications/unread';
  static String markNotificationAsRead(String id) => '/notifications/$id/read';
  static const String markAllAsRead = '/notifications/read-all';
  static String registerFcmToken = '$baseUrl/notifications/fcm-token';
  static String deleteFcmToken = '$baseUrl/notifications/fcm-token';
  static String deleteNotification(String id) => '/notifications/$id';
  static const String deleteAllNotifications = '/notifications/delete-all';

  // Advertisements
  static const String advertisements = '/advertisements';
  static const String activeAdvertisements = '/advertisements/active';

  // Persons (Profile) Endpoints
  static const String persons = '/persons';
  static const String myProfile = '/persons/me';
  static String personById(String id) => '/persons/$id';
  static const String uploadPhoto = '/persons/me/photo';
  static const String deletePhoto = '/persons/me/photo';
  static const String deleteAccount = '/persons/me';
  static const String myStatistics = '/persons/me/statistics';

  // Dashboard Endpoints
  static const String dashboard = '/dashboard';
  static const String dashboardSummary = '/dashboard/summary';

  // Timeout
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
