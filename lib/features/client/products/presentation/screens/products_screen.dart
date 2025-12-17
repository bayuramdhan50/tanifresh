import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tanifresh/core/theme/app_colors.dart';
import 'package:tanifresh/core/theme/app_text_styles.dart';
import 'package:tanifresh/core/theme/app_theme.dart';
import 'package:tanifresh/core/utils/formatters.dart';
import 'package:tanifresh/shared/widgets/loading/loading_indicator.dart';
import 'package:tanifresh/shared/widgets/buttons/custom_button.dart';
import '../providers/product_provider.dart';
import 'package:tanifresh/features/client/cart/presentation/providers/cart_provider.dart';
import 'package:tanifresh/features/client/cart/presentation/screens/cart_screen.dart';

/// Full products catalog screen with search and filter
class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Produk'),
        actions: [
          // Cart icon with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
              ),
              if (cartProvider.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '${cartProvider.itemCount}',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppTheme.spacingS),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: productProvider.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          productProvider.searchProducts('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
              ),
              onChanged: (value) {
                productProvider.searchProducts(value);
              },
            ),
          ),

          // Category filter chips
          if (productProvider.categories.isNotEmpty)
            SizedBox(
              height: 50,
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
                scrollDirection: Axis.horizontal,
                children: [
                  FilterChip(
                    label: const Text('Semua'),
                    selected: productProvider.selectedCategory == null,
                    onSelected: (_) => productProvider.filterByCategory(null),
                  ),
                  const SizedBox(width: AppTheme.spacingS),
                  ...productProvider.categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: AppTheme.spacingS),
                      child: FilterChip(
                        label: Text(category),
                        selected: productProvider.selectedCategory == category,
                        onSelected: (_) =>
                            productProvider.filterByCategory(category),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

          const SizedBox(height: AppTheme.spacingS),

          // Products grid
          Expanded(
            child: productProvider.isLoading
                ? const LoadingIndicator(message: 'Memuat produk...')
                : productProvider.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: AppTheme.spacingM),
                            Text(
                              'Gagal memuat produk',
                              style: AppTextStyles.h4,
                            ),
                            const SizedBox(height: AppTheme.spacingS),
                            Text(
                              productProvider.error!,
                              style: AppTextStyles.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppTheme.spacingL),
                            ElevatedButton(
                              onPressed: () => productProvider.fetchProducts(),
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      )
                    : productProvider.products.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.inventory_2_outlined,
                                  size: 64,
                                  color: AppColors.textHint,
                                ),
                                const SizedBox(height: AppTheme.spacingM),
                                Text(
                                  'Produk tidak ditemukan',
                                  style: AppTextStyles.h4,
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(AppTheme.spacingM),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.7,
                              crossAxisSpacing: AppTheme.spacingM,
                              mainAxisSpacing: AppTheme.spacingM,
                            ),
                            itemCount: productProvider.products.length,
                            itemBuilder: (context, index) {
                              final product = productProvider.products[index];
                              return _ProductCard(product: product);
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

/// Product card widget
class _ProductCard extends StatelessWidget {
  final dynamic product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final isInCart = cartProvider.isInCart(product.id);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.2),
                  AppColors.primary.withOpacity(0.1),
                ],
              ),
            ),
            child: const Icon(
              Icons.shopping_basket,
              size: 48,
              color: AppColors.primary,
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          product.name,
                          style: AppTextStyles.h4,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${Formatters.formatCurrency(product.price)}/${product.unit}',
                          style: AppTextStyles.priceSmall,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: product.isInStock
                                ? AppColors.success.withOpacity(0.1)
                                : AppColors.error.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusS),
                          ),
                          child: Text(
                            product.isInStock
                                ? 'Stok: ${product.stock.toInt()}'
                                : 'Habis',
                            style: AppTextStyles.caption.copyWith(
                              color: product.isInStock
                                  ? AppColors.success
                                  : AppColors.error,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Add to cart button
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton.icon(
                      onPressed: product.isInStock
                          ? () => _showAddToCartDialog(context, product)
                          : null,
                      icon: Icon(
                        isInCart ? Icons.check : Icons.add_shopping_cart,
                        size: 18,
                      ),
                      label: Text(
                        isInCart ? 'Di Keranjang' : 'Tambah',
                        style: AppTextStyles.buttonSmall,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingS,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddToCartDialog(BuildContext context, dynamic product) {
    final TextEditingController quantityController =
        TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.name, style: AppTextStyles.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              product.description,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppTheme.spacingL),
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
            child: const Text('Tambah ke Keranjang'),
          ),
        ],
      ),
    );
  }
}
