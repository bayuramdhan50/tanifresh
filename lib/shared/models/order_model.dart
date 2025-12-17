/// Order model for TaniFresh app
class Order {
  final String id;
  final String userId;
  final String? userName;
  final List<OrderItem> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final String status; // 'pending', 'approved', 'rejected', 'delivered'
  final String? notes;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Order({
    required this.id,
    required this.userId,
    this.userName,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.status,
    this.notes,
    this.rejectionReason,
    required this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['user_id'] ?? json['userId'] ?? '',
      userName: json['user_name'] ?? json['userName'],
      items: (json['items'] as List?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      subtotal: _parseDouble(json['subtotal']),
      discount: _parseDouble(json['discount']),
      tax: _parseDouble(json['tax']),
      total: _parseDouble(json['total']),
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      rejectionReason: json['rejection_reason'] ?? json['rejectionReason'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'total': total,
      'status': status,
      'notes': notes,
      'rejection_reason': rejectionReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Helper method to parse double from dynamic JSON value
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

/// Order item model
class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final double quantity;
  final String unit;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.unit,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'] ?? json['productId'] ?? '',
      productName: json['product_name'] ?? json['productName'] ?? '',
      price: _parseDouble(json['price']),
      quantity: _parseDouble(json['quantity']),
      unit: json['unit'] ?? 'Kg',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'unit': unit,
    };
  }

  double get totalPrice => price * quantity;

  /// Helper method to parse double from dynamic JSON value
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
