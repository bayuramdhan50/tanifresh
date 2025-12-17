import '../constants/app_constants.dart';

/// Price calculator with business logic for discounts and tax
class PriceCalculator {
  /// Calculate total price with tax and discounts
  static PriceBreakdown calculate(List<CartItem> items) {
    if (items.isEmpty) {
      return PriceBreakdown(
        subtotal: 0,
        discount: 0,
        tax: 0,
        total: 0,
        discountType: null,
      );
    }

    // Calculate subtotal
    double subtotal = items.fold(0.0, (sum, item) {
      return sum + (item.price * item.quantity);
    });

    // Calculate total weight
    double totalWeight = items.fold(0.0, (sum, item) {
      return sum + item.quantity;
    });

    // Determine discount
    double discount = 0;
    String? discountType;

    // Check for value discount (>= 1 million = 10% off)
    if (subtotal >= AppConstants.valueDiscountThreshold) {
      discount = subtotal * AppConstants.valueDiscountRate;
      discountType = 'Diskon Pembelian (10%)';
    }
    // Check for bulk discount (>= 50kg = 5% off)
    else if (totalWeight >= AppConstants.bulkDiscountThreshold) {
      discount = subtotal * AppConstants.bulkDiscountRate;
      discountType = 'Diskon Grosir (5%)';
    }

    // Calculate tax on discounted amount
    double afterDiscount = subtotal - discount;
    double tax = afterDiscount * AppConstants.taxRate;

    // Calculate final total
    double total = afterDiscount + tax;

    return PriceBreakdown(
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      total: total,
      discountType: discountType,
    );
  }
}

/// Cart item model for price calculation
class CartItem {
  final String productId;
  final String name;
  final double price;
  final double quantity;
  final String unit;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.unit,
  });
}

/// Price breakdown result
class PriceBreakdown {
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final String? discountType;

  PriceBreakdown({
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    this.discountType,
  });
}
