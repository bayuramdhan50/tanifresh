import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tanifresh/core/theme/app_colors.dart';
import 'package:tanifresh/core/theme/app_text_styles.dart';
import 'package:tanifresh/core/theme/app_theme.dart';
import 'package:tanifresh/features/admin/products/presentation/providers/admin_products_provider.dart';
import 'package:tanifresh/features/admin/products/presentation/screens/product_form_screen.dart';
import 'package:tanifresh/shared/models/product_model.dart';

/// Admin products management screen
class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProductsProvider>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<AdminProductsProvider>().refreshProducts(),
          ),
        ],
      ),
      body: Consumer<AdminProductsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 64, color: AppColors.error),
                  const SizedBox(height: AppTheme.spacingM),
                  Text('Error: ${provider.error}'),
                  const SizedBox(height: AppTheme.spacingM),
                  ElevatedButton(
                    onPressed: () => provider.refreshProducts(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (provider.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2_outlined,
                      size: 64, color: AppColors.textHint),
                  const SizedBox(height: AppTheme.spacingM),
                  Text('Belum ada produk', style: AppTextStyles.h4),
                  const SizedBox(height: AppTheme.spacingM),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToForm(context, null),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Produk Pertama'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            itemCount: provider.products.length,
            itemBuilder: (context, index) {
              return _buildProductCard(provider.products[index], provider);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Produk'),
      ),
    );
  }

  Widget _buildProductCard(Product product, AdminProductsProvider provider) {
    final isLowStock = product.stock < 10;

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Row(
          children: [
            // Product icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.15),
                    AppColors.primary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Icon(
                Icons.shopping_basket,
                size: 32,
                color: AppColors.primary.withOpacity(0.7),
              ),
            ),

            const SizedBox(width: AppTheme.spacingM),

            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.h4,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTheme.spacingS / 2),
                  Text(
                    'Rp ${product.price.toInt()}/${product.unit}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingS / 2),
                  Row(
                    children: [
                      Icon(
                        isLowStock ? Icons.warning : Icons.check_circle,
                        size: 14,
                        color: isLowStock ? AppColors.error : AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Stok: ${product.stock.toInt()} ${product.unit}',
                        style: AppTextStyles.caption.copyWith(
                          color:
                              isLowStock ? AppColors.error : AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action buttons
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  color: AppColors.primary,
                  onPressed: () => _navigateToForm(context, product),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  color: AppColors.error,
                  onPressed: () => _confirmDelete(product, provider),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToForm(BuildContext context, Product? product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductFormScreen(product: product),
      ),
    );

    if (result == true && mounted) {
      context.read<AdminProductsProvider>().refreshProducts();
    }
  }

  void _confirmDelete(Product product, AdminProductsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Apakah Anda yakin ingin menghapus "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.deleteProduct(product.id);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Produk berhasil dihapus'
                          : 'Gagal menghapus produk',
                    ),
                    backgroundColor:
                        success ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
