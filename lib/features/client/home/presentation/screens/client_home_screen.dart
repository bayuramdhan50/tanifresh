import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tanifresh/core/theme/app_colors.dart';
import 'package:tanifresh/core/theme/app_text_styles.dart';
import 'package:tanifresh/core/theme/app_theme.dart';
import 'package:tanifresh/features/auth/presentation/providers/auth_provider.dart';
import 'package:tanifresh/features/auth/presentation/screens/login_screen.dart';
import 'package:tanifresh/features/client/products/presentation/screens/products_screen.dart';
import 'package:tanifresh/features/client/products/presentation/providers/product_provider.dart';
import 'package:tanifresh/features/client/products/presentation/screens/product_detail_screen.dart';
import 'package:tanifresh/features/client/orders/presentation/providers/order_provider.dart';
import 'package:tanifresh/features/client/orders/presentation/screens/order_detail_screen.dart';
import 'package:tanifresh/shared/models/order_model.dart';
import 'package:tanifresh/shared/providers/notification_provider.dart';
import 'package:tanifresh/features/client/profile/presentation/screens/delivery_address_screen.dart';
import 'package:tanifresh/features/client/profile/presentation/screens/settings_screen.dart';
import 'package:tanifresh/features/client/profile/presentation/screens/help_screen.dart';
import 'package:tanifresh/shared/screens/about_screen.dart';
import 'package:tanifresh/features/client/statistics/presentation/screens/client_statistics_screen.dart';
import 'package:tanifresh/shared/screens/supplier_map_screen.dart';
import 'package:tanifresh/shared/screens/chat_screen.dart';

/// Client home screen with bottom navigation
class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // Connect notification provider to order provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationProvider = context.read<NotificationProvider>();
      final orderProvider = context.read<OrderProvider>();
      orderProvider.setNotificationProvider(notificationProvider);
    });

    _pages = [
      ClientDashboardPage(onNavigateToProducts: () => _navigateToTab(1)),
      const ClientProductsPage(),
      const ClientOrdersPage(),
      ClientProfilePage(onNavigateToOrders: () => _navigateToTab(2)),
    ];
  }

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

/// Dashboard page
class ClientDashboardPage extends StatefulWidget {
  final VoidCallback onNavigateToProducts;

  const ClientDashboardPage({super.key, required this.onNavigateToProducts});

  @override
  State<ClientDashboardPage> createState() => _ClientDashboardPageState();
}

class _ClientDashboardPageState extends State<ClientDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
      context.read<OrderProvider>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final productProvider = context.watch<ProductProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final userName = authProvider.user?.name ?? 'Pengguna';

    // Calculate order stats
    final pendingOrders = orderProvider.getOrdersByStatus('pending').length;
    final approvedOrders = orderProvider.getOrdersByStatus('approved').length;

    // Get top products (first 4)
    final topProducts = productProvider.products.take(4).toList();

    return CustomScrollView(
      slivers: [
        // App bar
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Selamat Datang,',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingS / 2),
                      Text(
                        userName,
                        style: AppTextStyles.h1.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Content
        SliverPadding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Stats cards with real data
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.pending_actions,
                      label: 'Pending',
                      value: '$pendingOrders',
                      color: AppColors.statusPending,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.check_circle_outline,
                      label: 'Disetujui',
                      value: '$approvedOrders',
                      color: AppColors.statusApproved,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacingL),

              // Section header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Produk Populer',
                    style: AppTextStyles.h3,
                  ),
                  TextButton(
                    onPressed: widget.onNavigateToProducts,
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacingM),

              // Product grid with real data
              if (productProvider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppTheme.spacingXl),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (topProducts.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingXl),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 48,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        Text(
                          'Belum ada produk',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppTheme.spacingM,
                    crossAxisSpacing: AppTheme.spacingM,
                    childAspectRatio: 0.8,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: topProducts.length,
                  itemBuilder: (context, index) {
                    final product = topProducts[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailScreen(product: product),
                          ),
                        );
                      },
                      child: _buildProductCard(
                        name: product.name,
                        price: product.price,
                        unit: product.unit,
                        stock: product.stock,
                      ),
                    );
                  },
                ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(color: color.withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            value,
            style: AppTextStyles.h1.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS / 2),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard({
    required String name,
    required double price,
    required String unit,
    required double stock,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder with gradient
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.15),
                  AppColors.primary.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusL),
                topRight: Radius.circular(AppTheme.radiusL),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.shopping_basket,
                size: 56,
                color: AppColors.primary.withOpacity(0.7),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.h4.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp ${price.toInt()}/$unit',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      stock > 0 ? Icons.check_circle : Icons.cancel,
                      size: 12,
                      color: stock > 0 ? AppColors.success : AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        stock > 0 ? '${stock.toInt()} $unit' : 'Habis',
                        style: AppTextStyles.caption.copyWith(
                          color:
                              stock > 0 ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Products page
class ClientProductsPage extends StatelessWidget {
  const ClientProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Import the ProductsScreen
    return const ProductsScreen();
  }
}

/// Orders page
class ClientOrdersPage extends StatefulWidget {
  const ClientOrdersPage({super.key});

  @override
  State<ClientOrdersPage> createState() => _ClientOrdersPageState();
}

class _ClientOrdersPageState extends State<ClientOrdersPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<OrderProvider>().refreshOrders(),
          ),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orderProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 64, color: AppColors.error),
                  const SizedBox(height: AppTheme.spacingM),
                  Text('Error: ${orderProvider.error}'),
                  const SizedBox(height: AppTheme.spacingM),
                  ElevatedButton(
                    onPressed: () => orderProvider.refreshOrders(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (orderProvider.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined,
                      size: 64, color: AppColors.textHint),
                  const SizedBox(height: AppTheme.spacingM),
                  Text('Belum ada pesanan', style: AppTextStyles.h4),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            itemCount: orderProvider.orders.length,
            itemBuilder: (context, index) {
              final order = orderProvider.orders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailScreen(order: order),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Order #${order.id.substring(0, 8)}',
                                style: AppTextStyles.h4),
                            _buildStatusBadge(order.status),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingS),
                        Text(
                          _formatDate(order.createdAt),
                          style: AppTextStyles.caption,
                        ),
                        const Divider(height: AppTheme.spacingL),
                        ...order.items.map((item) => Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppTheme.spacingS / 2),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                        '${item.productName} (${item.quantity.toInt()} ${item.unit})'),
                                  ),
                                  Text(
                                    'Rp ${item.price.toInt()}',
                                    style: AppTextStyles.bodyMedium
                                        .copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            )),
                        const Divider(height: AppTheme.spacingL),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total', style: AppTextStyles.h4),
                            Text(
                              'Rp ${order.total.toInt()}',
                              style: AppTextStyles.h3
                                  .copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = AppColors.statusPending;
        label = 'Pending';
        break;
      case 'approved':
        color = AppColors.statusApproved;
        label = 'Disetujui';
        break;
      case 'rejected':
        color = AppColors.statusRejected;
        label = 'Ditolak';
        break;
      case 'delivered':
        color = AppColors.success;
        label = 'Selesai';
        break;
      default:
        color = AppColors.textSecondary;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

/// Profile page
class ClientProfilePage extends StatelessWidget {
  final VoidCallback onNavigateToOrders;

  const ClientProfilePage({super.key, required this.onNavigateToOrders});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        children: [
          // Profile header
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  user?.name ?? '',
                  style: AppTextStyles.h2.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  user?.email ?? '',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingL),

          // Menu items
          _buildMenuItem(
            icon: Icons.receipt_long,
            title: 'Riwayat Pesanan',
            onTap: onNavigateToOrders,
          ),
          _buildMenuItem(
            icon: Icons.location_on,
            title: 'Alamat Pengiriman',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DeliveryAddressScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.settings,
            title: 'Pengaturan',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.bar_chart,
            title: 'Statistik Saya',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ClientStatisticsScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Bantuan',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.map_outlined,
            title: 'Peta Supplier',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SupplierMapScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.chat_bubble_outline,
            title: 'Chat dengan Admin',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatScreen(
                    otherUserId: 'admin-001',
                    otherUserName: 'Admin TaniFresh',
                    isAdmin: false,
                  ),
                ),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'Tentang Aplikasi',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: AppTheme.spacingL),

          // Logout button
          ElevatedButton(
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: AppTextStyles.bodyMedium),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
