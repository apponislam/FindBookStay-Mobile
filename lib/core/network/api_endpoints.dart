/// Centralized API Endpoints for FindBookStay
/// All routes are relative to [EnvConfig.apiBaseUrl].
abstract class ApiEndpoints {
  // Base API Version Prefix
  static const String apiVersion = '/api/v1';

  // Authentication & User Management
  static const String authLogin = '$apiVersion/auth/login';
  static const String authRegister = '$apiVersion/auth/register';
  static const String authRefreshToken = '$apiVersion/auth/refresh-token';
  static const String authLogout = '$apiVersion/auth/logout';
  static const String authMe = '$apiVersion/auth/me';
  static const String authForgotPassword = '$apiVersion/auth/forgot-password';
  static const String authVerifyOtp = '$apiVersion/auth/verify-otp';
  static const String authResendOtp = '$apiVersion/auth/resend-otp';
  static const String authVerifyEmail = '$apiVersion/auth/verify-email';
  static const String authResendVerification = '$apiVersion/auth/resend-verification';
  static const String authResetPassword = '$apiVersion/auth/reset-password';
  static const String authUpdateProfile = '$apiVersion/auth/profile';

  // Properties & Stays
  static const String properties = '$apiVersion/properties';
  static const String featuredProperties = '$apiVersion/properties/featured';
  static String propertyDetails(String id) => '$apiVersion/properties/$id';
  static String propertyReviews(String id) =>
      '$apiVersion/properties/$id/reviews';

  // Sports Turfs & Venues
  static const String turfs = '$apiVersion/turfs';
  static const String featuredTurfs = '$apiVersion/turfs/featured';
  static String turfDetails(String id) => '$apiVersion/turfs/$id';
  static String turfSlots(String id, String date) =>
      '$apiVersion/turfs/$id/slots?date=$date';

  // Bookings & Reservations
  static const String bookings = '$apiVersion/bookings';
  static const String myBookings = '$apiVersion/bookings/my';
  static String bookingDetails(String id) => '$apiVersion/bookings/$id';
  static String cancelBooking(String id) => '$apiVersion/bookings/$id/cancel';

  // Wishlist & Saved Items
  static const String wishlist = '$apiVersion/wishlist';
  static String wishlistToggle(String itemId) =>
      '$apiVersion/wishlist/toggle/$itemId';

  // Messages & Inbox
  static const String conversations = '$apiVersion/conversations';
  static String messages(String conversationId) =>
      '$apiVersion/conversations/$conversationId/messages';
}
