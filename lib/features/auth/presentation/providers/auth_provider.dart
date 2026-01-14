import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/models/user_model.dart';
import '../../data/services/auth_service.dart';

/// Authentication provider using ChangeNotifier
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;
  bool get isClient => _user?.role == 'client';
  bool get isAdmin => _user?.role == 'admin';

  /// Initialize auth state from storage
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final hasToken = await _authService.loadAuthData();

      if (hasToken) {
        // Try to get user profile
        try {
          _user = await _authService.getProfile();
          _isAuthenticated = true;
        } catch (e) {
          // Token might be expired, clear it
          await _authService.logout();
          _isAuthenticated = false;
        }
      } else {
        _isAuthenticated = false;
      }
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register new user
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? address,
    String? phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.register(
        name: name,
        email: email,
        password: password,
        role: role,
        address: address,
        phone: phone,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      // Check if user is active
      final user = User.fromJson(response['user']);

      if (!user.isActive) {
        _error = 'Akun Anda belum disetujui oleh admin';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _user = user;
      _isAuthenticated = true;

      // Save userId and isAdmin to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      // Assuming _authService.login already handles saving the token,
      // we only need to save additional user-specific data here.
      await prefs.setString(
          'userId', _user!.id.toString()); // Store user ID for chat!
      await prefs.setBool('isAdmin', _user!.role == 'admin'); // Check role

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _isAuthenticated = false;
    _error = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
