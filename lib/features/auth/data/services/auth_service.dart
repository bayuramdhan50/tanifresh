import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/user_model.dart';

/// Authentication service for TaniFresh app
class AuthService {
  final ApiClient _apiClient = ApiClient();

  /// Register new user
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? address,
    String? phone,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.register,
        body: {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
          'address': address,
          'phone': phone,
        },
        requiresAuth: false,
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        body: {
          'email': email,
          'password': password,
        },
        requiresAuth: false,
      );

      // Save token and user data
      if (response.data['token'] != null) {
        await _saveAuthData(response.data);
      }

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Get user profile
  Future<User> getProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.profile);
      return User.fromJson(response.data['user']);
    } catch (e) {
      rethrow;
    }
  }

  /// Save authentication data to local storage
  Future<void> _saveAuthData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(AppConstants.keyAuthToken, data['token']);

    if (data['user'] != null) {
      final user = User.fromJson(data['user']);
      await prefs.setString(AppConstants.keyUserId, user.id);
      await prefs.setString(AppConstants.keyUserRole, user.role);
      await prefs.setString(AppConstants.keyUserName, user.name);
      await prefs.setString(AppConstants.keyUserEmail, user.email);
    }

    // Set token in API client
    _apiClient.setAuthToken(data['token']);
  }

  /// Load authentication data from local storage
  Future<bool> loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.keyAuthToken);

    if (token != null) {
      _apiClient.setAuthToken(token);
      return true;
    }

    return false;
  }

  /// Get saved user data
  Future<Map<String, String?>> getSavedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getString(AppConstants.keyUserId),
      'role': prefs.getString(AppConstants.keyUserRole),
      'name': prefs.getString(AppConstants.keyUserName),
      'email': prefs.getString(AppConstants.keyUserEmail),
    };
  }

  /// Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _apiClient.clearAuthToken();
  }
}
