import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

/// Service for handling all notification operations
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Payload will contain order ID or other navigation data
    // Navigation will be handled by the app's navigation system
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (!_isInitialized) await initialize();

    // For Android 13+
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    // For iOS
    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true; // Other platforms
  }

  /// Show a basic notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'tanifresh_channel',
      'TaniFresh Notifications',
      channelDescription: 'General notifications for TaniFresh app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  /// Show order notification
  Future<void> showOrderNotification({
    required String orderId,
    required String status,
    required String message,
  }) async {
    String title;
    String body;

    switch (status.toLowerCase()) {
      case 'approved':
        title = '✅ Pesanan Disetujui';
        body = message.isNotEmpty
            ? message
            : 'Pesanan Anda telah disetujui dan akan segera diproses';
        break;
      case 'rejected':
        title = '❌ Pesanan Ditolak';
        body = message.isNotEmpty
            ? message
            : 'Maaf, pesanan Anda ditolak. Silakan coba lagi';
        break;
      case 'delivered':
        title = '🚚 Pesanan Dikirim';
        body = message.isNotEmpty
            ? message
            : 'Pesanan Anda sedang dalam perjalanan';
        break;
      case 'completed':
        title = '✓ Pesanan Selesai';
        body = message.isNotEmpty
            ? message
            : 'Terima kasih! Pesanan Anda telah selesai';
        break;
      default:
        title = 'Update Pesanan';
        body = message;
    }

    await showNotification(
      id: orderId.hashCode,
      title: title,
      body: body,
      payload: 'order:$orderId',
    );
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
