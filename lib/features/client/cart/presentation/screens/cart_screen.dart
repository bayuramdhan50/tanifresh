import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tanifresh/core/theme/app_colors.dart';
import 'package:tanifresh/core/theme/app_text_styles.dart';
import 'package:tanifresh/core/theme/app_theme.dart';
import 'package:tanifresh/core/utils/formatters.dart';
import 'package:tanifresh/core/network/api_client.dart';
import 'package:tanifresh/core/constants/api_constants.dart';
import 'package:tanifresh/shared/widgets/buttons/custom_button.dart';
import 'package:tanifresh/shared/models/order_model.dart';
import 'package:tanifresh/features/client/cart/presentation/providers/cart_provider.dart';
import 'package:tanifresh/features/client/products/presentation/providers/product_provider.dart';

/// Shopping cart screen with checkout
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
        actions: [
          if (cartProvider.itemCount > 0)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Kosongkan Keranjang?'),
                    content: const Text(
                      'Semua item akan dihapus dari keranjang',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          cartProvider.clearCart();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                        ),
                        child: const Text('Kosongkan'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Kosongkan'),
            ),
        ],
      ),
      body: cartProvider.itemCount == 0
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  Text(
                    'Keranjang kosong',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    'Tambahkan produk untuk memulai belanja',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Mulai Belanja'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    itemCount: cartProvider.items.length,
                    itemBuilder: (context, index) {
                      final entry = cartProvider.items.entries.toList()[index];
                      return _CartItemCard(
                        cartItem: entry.value,
                        onRemove: () => cartProvider.removeItem(entry.key),
                        onUpdateQuantity: (quantity) =>
                            cartProvider.updateQuantity(entry.key, quantity),
                      );
                    },
                  ),
                ),
                _CheckoutSection(),
              ],
            ),
    );
  }
}

/// Cart item card
class _CartItemCard extends StatelessWidget {
  final dynamic cartItem;
  final VoidCallback onRemove;
  final Function(double) onUpdateQuantity;

  const _CartItemCard({
    required this.cartItem,
    required this.onRemove,
    required this.onUpdateQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Row(
          children: [
            // Product image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.2),
                    AppColors.primary.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: const Icon(
                Icons.shopping_basket,
                color: AppColors.primary,
                size: 32,
              ),
            ),

            const SizedBox(width: AppTheme.spacingM),

            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.product.name,
                    style: AppTextStyles.h4,
                  ),
                  const SizedBox(height: AppTheme.spacingS / 2),
                  Text(
                    Formatters.formatCurrency(cartItem.product.price),
                    style: AppTextStyles.priceSmall,
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Row(
                    children: [
                      // Decrease button
                      IconButton(
                        onPressed: () {
                          if (cartItem.quantity > 1) {
                            onUpdateQuantity(cartItem.quantity - 1);
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                        color: AppColors.primary,
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),

                      const SizedBox(width: AppTheme.spacingM),

                      // Quantity
                      Text(
                        '${cartItem.quantity.toInt()} ${cartItem.product.unit}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(width: AppTheme.spacingM),

                      // Increase button
                      IconButton(
                        onPressed: () {
                          if (cartItem.quantity < cartItem.product.stock) {
                            onUpdateQuantity(cartItem.quantity + 1);
                          }
                        },
                        icon: const Icon(Icons.add_circle_outline),
                        color: AppColors.primary,
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Remove button
            Column(
              children: [
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.error,
                ),
                Text(
                  Formatters.formatCurrency(cartItem.totalPrice),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Checkout section with price breakdown
class _CheckoutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final breakdown = cartProvider.getPriceBreakdown();

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PriceRow(
            label: 'Subtotal',
            value: Formatters.formatCurrency(breakdown.subtotal),
          ),
          if (breakdown.discount > 0) ...[
            const SizedBox(height: AppTheme.spacingS),
            _PriceRow(
              label: breakdown.discountType ?? 'Diskon',
              value: '- ${Formatters.formatCurrency(breakdown.discount)}',
              valueColor: AppColors.success,
            ),
          ],
          const SizedBox(height: AppTheme.spacingS),
          _PriceRow(
            label: 'PPN (11%)',
            value: Formatters.formatCurrency(breakdown.tax),
          ),
          const Divider(height: AppTheme.spacingL),
          _PriceRow(
            label: 'Total',
            value: Formatters.formatCurrency(breakdown.total),
            isTotal: true,
          ),
          const SizedBox(height: AppTheme.spacingL),
          CustomButton(
            text: 'Checkout (${cartProvider.totalItemsQuantity} Item)',
            icon: Icons.payment,
            onPressed: () => _handleCheckout(context),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCheckout(BuildContext context) async {
    final cartProvider = context.read<CartProvider>();
    final breakdown = cartProvider.getPriceBreakdown();

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: AppTheme.spacingM),
                Text('Memproses pesanan...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Prepare order items
      final items = cartProvider.items.values.map((item) {
        return {
          'product_id': item.product.id,
          'product_name': item.product.name,
          'price': item.product.price,
          'quantity': item.quantity,
          'unit': item.product.unit,
        };
      }).toList();

      // Create order
      final apiClient = ApiClient();
      await apiClient.post(
        ApiConstants.orders,
        body: {
          'items': items,
          'subtotal': breakdown.subtotal,
          'discount': breakdown.discount,
          'tax': breakdown.tax,
          'total': breakdown.total,
        },
      );

      // Clear cart
      cartProvider.clearCart();

      if (context.mounted) {
        Navigator.pop(context); // Close loading
        Navigator.pop(context); // Back to products

        // Show success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Pesanan berhasil dibuat! Menunggu persetujuan admin.'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat pesanan: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

/// Price row widget
class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final Color? valueColor;

  const _PriceRow({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal ? AppTextStyles.h3 : AppTextStyles.bodyMedium,
        ),
        Text(
          value,
          style:
              (isTotal ? AppTextStyles.h2 : AppTextStyles.bodyMedium).copyWith(
            color: valueColor ?? (isTotal ? AppColors.primary : null),
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
