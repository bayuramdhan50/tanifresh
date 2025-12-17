import 'package:flutter/material.dart';
import 'package:tanifresh/core/network/api_client.dart';
import 'package:tanifresh/core/constants/api_constants.dart';
import 'package:tanifresh/shared/models/order_model.dart';

/// Order provider for managing user orders
class OrderProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

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
        _orders = (response.data['orders'] as List)
            .map((json) => Order.fromJson(json))
            .toList();
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

  /// Refresh orders
  Future<void> refreshOrders() async {
    await fetchOrders();
  }
}
