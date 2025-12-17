import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tanifresh/core/services/notification_service.dart';

/// Provider for managing notification preferences and state
class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService;
  SharedPreferences? _prefs;

  // Notification preferences
  bool _notificationsEnabled = true;
  bool _orderNotifications = true;
  bool _promotionNotifications = false;
  bool _isInitialized = false;

  NotificationProvider(this._notificationService) {
    _initialize();
  }

  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get orderNotifications => _orderNotifications;
  bool get promotionNotifications => _promotionNotifications;
  bool get isInitialized => _isInitialized;

  /// Initialize provider and load preferences
  Future<void> _initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadPreferences();
      await _notificationService.initialize();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing NotificationProvider: $e');
    }
  }

  /// Load preferences from storage
  Future<void> _loadPreferences() async {
    _notificationsEnabled = _prefs?.getBool('notifications_enabled') ?? true;
    _orderNotifications = _prefs?.getBool('order_notifications') ?? true;
    _promotionNotifications =
        _prefs?.getBool('promotion_notifications') ?? false;
  }

  /// Save preferences to storage
  Future<void> _savePreferences() async {
    await _prefs?.setBool('notifications_enabled', _notificationsEnabled);
    await _prefs?.setBool('order_notifications', _orderNotifications);
    await _prefs?.setBool('promotion_notifications', _promotionNotifications);
  }

  /// Toggle main notifications
  Future<void> toggleNotifications(bool value) async {
    try {
      _notificationsEnabled = value;

      if (!value) {
        // If disabling, also disable all sub-notifications
        _orderNotifications = false;
        _promotionNotifications = false;
        // Cancel all existing notifications
        try {
          await _notificationService.cancelAllNotifications();
        } catch (e) {
          debugPrint('Error canceling notifications: $e');
          // Continue even if cancel fails
        }
      } else {
        // If enabling, request permissions
        try {
          await _notificationService.requestPermissions();
        } catch (e) {
          debugPrint('Error requesting permissions: $e');
          // Continue even if permission request fails
        }
      }

      await _savePreferences();
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling notifications: $e');
      // Revert the change if there was an error
      _notificationsEnabled = !value;
      notifyListeners();
    }
  }

  /// Toggle order notifications
  Future<void> toggleOrderNotifications(bool value) async {
    if (!_notificationsEnabled)
      return; // Can't enable if main notifications are off

    _orderNotifications = value;
    await _savePreferences();
    notifyListeners();
  }

  /// Toggle promotion notifications
  Future<void> togglePromotionNotifications(bool value) async {
    if (!_notificationsEnabled)
      return; // Can't enable if main notifications are off

    _promotionNotifications = value;
    await _savePreferences();
    notifyListeners();
  }

  /// Show order notification (if enabled)
  Future<void> showOrderNotification({
    required String orderId,
    required String status,
    String? message,
  }) async {
    // Only show if notifications are enabled
    if (!_notificationsEnabled || !_orderNotifications) {
      debugPrint('Order notifications are disabled');
      return;
    }

    await _notificationService.showOrderNotification(
      orderId: orderId,
      status: status,
      message: message ?? '',
    );
  }

  /// Show promotion notification (if enabled)
  Future<void> showPromotionNotification({
    required String title,
    required String body,
  }) async {
    // Only show if notifications are enabled
    if (!_notificationsEnabled || !_promotionNotifications) {
      debugPrint('Promotion notifications are disabled');
      return;
    }

    await _notificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: body,
    );
  }

  /// Show admin notification for new order
  Future<void> showAdminNewOrderNotification({
    required String orderId,
    required String userName,
  }) async {
    // Only show if notifications are enabled
    if (!_notificationsEnabled) {
      debugPrint('Admin notifications are disabled');
      return;
    }

    await _notificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: '🛒 Pesanan Baru Masuk',
      body: 'Pesanan #${orderId.substring(0, 8)} dari $userName',
    );
  }

  /// Show admin notification for new user registration
  Future<void> showAdminNewUserNotification({
    required String userName,
    required String userEmail,
  }) async {
    // Only show if notifications are enabled
    if (!_notificationsEnabled) {
      debugPrint('Admin notifications are disabled');
      return;
    }

    await _notificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: '👤 User Baru Perlu Approval',
      body: '$userName ($userEmail) menunggu persetujuan',
    );
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    return await _notificationService.requestPermissions();
  }
}
