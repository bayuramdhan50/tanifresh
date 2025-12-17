import 'package:flutter/material.dart';
import 'package:tanifresh/core/theme/app_colors.dart';
import 'package:tanifresh/core/theme/app_text_styles.dart';
import 'package:tanifresh/core/theme/app_theme.dart';
import 'package:tanifresh/core/utils/formatters.dart';
import 'package:tanifresh/shared/models/product_model.dart';
import 'package:provider/provider.dart';
import 'package:tanifresh/features/client/cart/presentation/providers/cart_provider.dart';

/// Product detail screen
class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final isInCart = cartProvider.isInCart(product.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.2),
                    AppColors.primary.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.shopping_basket,
                  size: 120,
                  color: AppColors.primary.withOpacity(0.7),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.name,
                    style: AppTextStyles.h1,
                  ),
                  const SizedBox(height: AppTheme.spacingS),

                  // Category
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingM,
                      vertical: AppTheme.spacingS / 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    ),
                    child: Text(
                      product.category,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingL),

                  // Price
                  Row(
                    children: [
                      Text(
                        'Harga',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${Formatters.formatCurrency(product.price)}/${product.unit}',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: AppTheme.spacingL * 2),

                  // Stock
                  Row(
                    children: [
                      Icon(
                        product.isInStock ? Icons.check_circle : Icons.cancel,
                        color: product.isInStock
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      Text(
                        product.isInStock
                            ? 'Stok: ${product.stock.toInt()} ${product.unit}'
                            : 'Stok Habis',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: product.isInStock
                              ? AppColors.success
                              : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppTheme.spacingL),

                  // Description
                  Text(
                    'Deskripsi',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    product.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingXl),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: ElevatedButton.icon(
            onPressed:
                product.isInStock ? () => _showAddToCartDialog(context) : null,
            icon: Icon(isInCart ? Icons.check : Icons.add_shopping_cart),
            label:
                Text(isInCart ? 'Sudah Di Keranjang' : 'Tambah ke Keranjang'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddToCartDialog(BuildContext context) {
    final TextEditingController quantityController =
        TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tambah ke Keranjang', style: AppTextStyles.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah (${product.unit})',
                hintText: 'Masukkan jumlah',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final quantity = double.tryParse(quantityController.text) ?? 0;
              if (quantity > 0 && quantity <= product.stock) {
                context.read<CartProvider>().addToCart(product, quantity);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} ditambahkan ke keranjang'),
                    backgroundColor: AppColors.success,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Jumlah tidak valid'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}
