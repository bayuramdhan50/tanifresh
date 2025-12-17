import 'package:flutter/material.dart';
import '../../../../../shared/models/product_model.dart';
import '../../../../../core/utils/price_calculator.dart';

/// Cart item with product and quantity
class CartItemModel {
  final Product product;
  double quantity;

  CartItemModel({
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.price * quantity;
}

/// Cart provider for managing shopping cart
class CartProvider with ChangeNotifier {
  final Map<String, CartItemModel> _items = {};

  Map<String, CartItemModel> get items => {..._items};

  int get itemCount => _items.length;

  int get totalItemsQuantity =>
      _items.values.fold(0, (sum, item) => sum + item.quantity.toInt());

  /// Add product to cart
  void addToCart(Product product, double quantity) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity += quantity;
    } else {
      _items[product.id] = CartItemModel(
        product: product,
        quantity: quantity,
      );
    }
    notifyListeners();
  }

  /// Update quantity
  void updateQuantity(String productId, double quantity) {
    if (_items.containsKey(productId)) {
      if (quantity <= 0) {
        _items.remove(productId);
      } else {
        _items[productId]!.quantity = quantity;
      }
      notifyListeners();
    }
  }

  /// Remove item from cart
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  /// Clear cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  /// Get price breakdown
  PriceBreakdown getPriceBreakdown() {
    final cartItems = _items.values.map((item) {
      return CartItem(
        productId: item.product.id,
        name: item.product.name,
        price: item.product.price,
        quantity: item.quantity,
        unit: item.product.unit,
      );
    }).toList();

    return PriceCalculator.calculate(cartItems);
  }

  /// Check if product is in cart
  bool isInCart(String productId) {
    return _items.containsKey(productId);
  }

  /// Get cart item
  CartItemModel? getCartItem(String productId) {
    return _items[productId];
  }
}
