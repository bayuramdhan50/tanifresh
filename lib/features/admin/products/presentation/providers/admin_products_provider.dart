import 'package:flutter/material.dart';
import 'package:tanifresh/core/network/api_client.dart';
import 'package:tanifresh/core/constants/api_constants.dart';
import 'package:tanifresh/shared/models/product_model.dart';

/// Provider for admin product management
class AdminProductsProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch all products
  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiClient.loadToken();
      final response = await _apiClient.get(ApiConstants.products);

      if (response.data is Map && response.data['products'] is List) {
        _products = (response.data['products'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
      } else {
        _products = [];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create new product
  Future<bool> createProduct(Product product) async {
    try {
      await _apiClient.loadToken();
      final response = await _apiClient.post(
        ApiConstants.products,
        body: product.toJson(),
      );

      if (response.statusCode == 201) {
        await fetchProducts(); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update existing product
  Future<bool> updateProduct(String productId, Product product) async {
    try {
      await _apiClient.loadToken();
      final response = await _apiClient.put(
        '${ApiConstants.products}/$productId',
        body: product.toJson(),
      );

      if (response.statusCode == 200) {
        await fetchProducts(); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete product
  Future<bool> deleteProduct(String productId) async {
    try {
      await _apiClient.loadToken();
      final response = await _apiClient.delete(
        '${ApiConstants.products}/$productId',
      );

      if (response.statusCode == 200) {
        _products.removeWhere((p) => p.id == productId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Refresh products
  Future<void> refreshProducts() async {
    await fetchProducts();
  }
}
