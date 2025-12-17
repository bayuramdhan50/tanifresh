import 'package:flutter/material.dart';
import 'package:tanifresh/core/network/api_client.dart';
import 'package:tanifresh/core/constants/api_constants.dart';
import 'package:tanifresh/shared/models/order_model.dart';
import 'package:tanifresh/shared/providers/notification_provider.dart';

/// Order provider for managing user orders
class OrderProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  NotificationProvider? _notificationProvider;

  List<Order> _orders = [];
  Map<String, String> _previousOrderStatuses = {};
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Set notification provider for sending notifications
  void setNotificationProvider(NotificationProvider provider) {
    _notificationProvider = provider;
  }

  /// Get orders by status
  List<Order> getOrdersByStatus(String status) {
    return _orders.where((order) => order.status == status).toList();
  }

  /// Fetch all orders for current user
  Future<void> fetchOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiClient.loadToken();
      final response = await _apiClient.get(ApiConstants.orders);

      if (response.data is Map && response.data['orders'] is List) {
        final newOrders = (response.data['orders'] as List)
            .map((json) => Order.fromJson(json))
            .toList();

        // Check for status changes and send notifications
        await _checkForOrderUpdates(newOrders);

        _orders = newOrders;
      } else {
        _orders = [];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check for order status changes and send notifications
  Future<void> _checkForOrderUpdates(List<Order> newOrders) async {
    if (_notificationProvider == null) return;

    for (var newOrder in newOrders) {
      final previousStatus = _previousOrderStatuses[newOrder.id];

      // If status has changed, send notification
      if (previousStatus != null && previousStatus != newOrder.status) {
        await _sendOrderStatusNotification(newOrder, previousStatus);
      }

      // Update the status map
      _previousOrderStatuses[newOrder.id] = newOrder.status;
    }
  }

  /// Send notification for order status change
  Future<void> _sendOrderStatusNotification(
    Order order,
    String previousStatus,
  ) async {
    if (_notificationProvider == null) return;

    String message = '';

    switch (order.status.toLowerCase()) {
      case 'approved':
        message = 'Pesanan #${order.id.substring(0, 8)} telah disetujui';
        break;
      case 'rejected':
        message = 'Pesanan #${order.id.substring(0, 8)} ditolak';
        break;
      case 'delivered':
        message =
            'Pesanan #${order.id.substring(0, 8)} sedang dalam pengiriman';
        break;
      case 'completed':
        message = 'Pesanan #${order.id.substring(0, 8)} telah selesai';
        break;
    }

    if (message.isNotEmpty) {
      await _notificationProvider!.showOrderNotification(
        orderId: order.id,
        status: order.status,
        message: message,
      );
    }
  }

  /// Refresh orders
  Future<void> refreshOrders() async {
    await fetchOrders();
  }
}
