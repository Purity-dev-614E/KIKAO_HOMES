class AppEndpoints {
  static const String BASE_URL = "https://pgyckbnygqdlwkolimgk.supabase.co/functions/v1";

  final String submitVisit = '$BASE_URL/submit_visit_requests';
  final String approveVisit = '$BASE_URL/approve_visits';
  final String rejectVisit = '$BASE_URL/reject_visits';
  final String checkoutVisit = '$BASE_URL/checkout-visits';
  final String getMyVisits = '$BASE_URL/get-my-visits';
  final String adduser = '$BASE_URL/add-user';
  final String securityLogin = '$BASE_URL/security-login';
  final String securityLogout = '$BASE_URL/security-logout';
  final String assignSecurityOfficer = '$BASE_URL/assign-security-officer';
  final String adminSignup = '$BASE_URL/admin-signup';
  final String login = '$BASE_URL/login';
  final String setUserPassword = '$BASE_URL/set-user-password';
  final String getActiveVisits = '$BASE_URL/get-active-visits';
  final String sendSetPasswordEmail = '$BASE_URL/send-set-password-email';
  final String fetchUserById = '$BASE_URL/fetchUserById';
  final String getVisitsByPeriod = '$BASE_URL/get-visits-by-period';
  final String createNotification = '$BASE_URL/createnotification';
  final String getNotifications = '$BASE_URL/getnotifications';
  final String getNotificationById = '$BASE_URL/getunreadnotification';
  final String sendPushNotification = '$BASE_URL/sendpushnotification';
}