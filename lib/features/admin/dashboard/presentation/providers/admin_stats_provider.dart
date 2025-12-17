import 'package:flutter/material.dart';
import 'package:tanifresh/core/network/api_client.dart';
import 'package:tanifresh/core/constants/api_constants.dart';
import 'package:tanifresh/shared/providers/notification_provider.dart';

/// Provider for admin dashboard statistics
class AdminStatsProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  NotificationProvider? _notificationProvider;

  int _pendingUsersCount = 0;
  int _pendingOrdersCount = 0;
  int _completedOrdersCount = 0;
  int _totalProductsCount = 0;
  bool _isLoading = false;
  String? _error;

  // Track previous counts for notifications
  int _previousPendingUsersCount = 0;
  int _previousPendingOrdersCount = 0;

  int get pendingUsersCount => _pendingUsersCount;
  int get pendingOrdersCount => _pendingOrdersCount;
  int get completedOrdersCount => _completedOrdersCount;
  int get totalProductsCount => _totalProductsCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Set notification provider for sending notifications
  void setNotificationProvider(NotificationProvider provider) {
    _notificationProvider = provider;
  }

  /// Fetch all dashboard statistics
  Future<void> fetchStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiClient.loadToken();

      // Fetch pending users
      final usersResponse = await _apiClient.get(ApiConstants.pendingUsers);
      if (usersResponse.data is Map && usersResponse.data['users'] is List) {
        final newCount = (usersResponse.data['users'] as List).length;

        // Check for new users and send notification
        if (_previousPendingUsersCount > 0 &&
            newCount > _previousPendingUsersCount) {
          final users = usersResponse.data['users'] as List;
          final latestUser = users.first;
          await _notificationProvider?.showAdminNewUserNotification(
            userName: latestUser['name'] ?? 'User',
            userEmail: latestUser['email'] ?? '',
          );
        }

        _previousPendingUsersCount = newCount;
        _pendingUsersCount = newCount;
      }

      // Fetch orders
      final ordersResponse = await _apiClient.get(ApiConstants.orders);
      if (ordersResponse.data is Map && ordersResponse.data['orders'] is List) {
        final orders = ordersResponse.data['orders'] as List;
        final pendingOrders =
            orders.where((o) => o['status'] == 'pending').toList();
        final newPendingCount = pendingOrders.length;

        // Check for new orders and send notification
        if (_previousPendingOrdersCount > 0 &&
            newPendingCount > _previousPendingOrdersCount) {
          final latestOrder = pendingOrders.first;
          await _notificationProvider?.showAdminNewOrderNotification(
            orderId: latestOrder['id'] ?? '',
            userName: latestOrder['user_name'] ?? 'User',
          );
        }

        _previousPendingOrdersCount = newPendingCount;
        _pendingOrdersCount = newPendingCount;
        _completedOrdersCount = orders
            .where(
                (o) => o['status'] == 'delivered' || o['status'] == 'completed')
            .length;
      }

      // Fetch products
      final productsResponse = await _apiClient.get(ApiConstants.products);
      if (productsResponse.data is Map &&
          productsResponse.data['products'] is List) {
        _totalProductsCount =
            (productsResponse.data['products'] as List).length;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh statistics
  Future<void> refreshStats() async {
    await fetchStats();
  }
}
