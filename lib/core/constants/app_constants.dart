/// App-wide constants for TaniFresh
class AppConstants {
  // App info
  static const String appName = 'TaniFresh';
  static const String appVersion = '1.0.0';

  // User roles
  static const String roleClient = 'client';
  static const String roleAdmin = 'admin';

  // Order status
  static const String statusPending = 'pending';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';
  static const String statusDelivered = 'delivered';

  // Price calculation constants
  static const double taxRate = 0.11; // 11% PPN
  static const double bulkDiscountThreshold = 50.0; // kg
  static const double bulkDiscountRate = 0.05; // 5%
  static const double valueDiscountThreshold = 1000000.0; // Rp
  static const double valueDiscountRate = 0.10; // 10%

  // Local storage keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  static const String keyUserName = 'user_name';
  static const String keyUserEmail = 'user_email';

  // Product units
  static const List<String> productUnits = ['Kg', 'Ton', 'Kuintal'];

  // Weather conditions
  static const List<String> badWeatherConditions = [
    'Rain',
    'Thunderstorm',
    'Snow',
    'Drizzle',
  ];

  // Pagination
  static const int itemsPerPage = 20;

  // Cache duration
  static const Duration weatherCacheDuration = Duration(minutes: 5);

  // Default location for weather
  static const String defaultCity = 'Bandung';
}
