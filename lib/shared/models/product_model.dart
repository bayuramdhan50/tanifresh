/// Product model for TaniFresh app
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String unit; // 'Kg', 'Ton', 'Kuintal'
  final double stock;
  final String? imageUrl;
  final String category;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.stock,
    this.imageUrl,
    required this.category,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: _parseDouble(json['price']),
      unit: json['unit'] ?? 'Kg',
      stock: _parseDouble(json['stock']),
      imageUrl: json['image_url'] ?? json['imageUrl'],
      category: json['category'] ?? 'Sayuran',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'unit': unit,
      'stock': stock,
      'image_url': imageUrl,
      'category': category,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isInStock => stock > 0;

  /// Helper method to parse double from dynamic JSON value
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
