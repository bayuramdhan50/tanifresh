/// API endpoint constants for TaniFresh backend
class ApiConstants {
  // Base URL - Using 10.0.2.2 for Android Emulator (10.0.2.2 refers to host machine's localhost)
  // For iOS Simulator use: http://localhost:3000/api
  // For Physical Device use: http://YOUR_COMPUTER_IP:3000/api
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String profile = '/auth/profile';

  // Products endpoints
  static const String products = '/products';
  static String productById(String id) => '/products/$id';

  // Orders endpoints
  static const String orders = '/orders';
  static String orderById(String id) => '/orders/$id';
  static String updateOrderStatus(String id) => '/orders/$id/status';

  // Admin endpoints
  static const String pendingUsers = '/admin/pending-users';
  static String approveUser(String id) => '/admin/users/$id/approve';
  static String rejectUser(String id) => '/admin/users/$id/reject';

  // Weather endpoint
  static const String weather = '/weather';

  // OpenWeather API (direct fallback)
  static const String openWeatherApiKey = '0b42924c0348700e9eef5dc2d62e889b';
  static String openWeatherUrl(String city) =>
      'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$openWeatherApiKey&units=metric&lang=id';
}
