import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tanifresh/core/theme/app_colors.dart';
import 'package:tanifresh/core/theme/app_text_styles.dart';
import 'package:tanifresh/core/theme/app_theme.dart';
import 'package:tanifresh/features/auth/presentation/providers/auth_provider.dart';
import 'package:tanifresh/features/auth/presentation/screens/login_screen.dart';
import 'package:tanifresh/features/admin/weather/data/weather_service.dart';
import 'package:tanifresh/features/admin/user_approval/presentation/screens/user_approval_screen.dart';
import 'package:tanifresh/features/admin/dashboard/presentation/providers/admin_stats_provider.dart';
import 'package:tanifresh/features/admin/orders/presentation/screens/admin_orders_screen.dart';
import 'package:tanifresh/features/admin/products/presentation/screens/admin_products_screen.dart';
import 'package:tanifresh/shared/providers/notification_provider.dart';
import 'package:tanifresh/shared/screens/about_screen.dart';
import 'package:tanifresh/features/admin/analytics/presentation/screens/admin_analytics_screen.dart';
import 'package:tanifresh/shared/screens/supplier_map_screen.dart';
import 'package:tanifresh/features/admin/chat/presentation/screens/admin_chat_list_screen.dart';

/// Admin dashboard screen with weather widget
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final WeatherService _weatherService = WeatherService();
  WeatherData? _weather;
  bool _loadingWeather = true;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadWeather();

    // Connect notification provider to admin stats provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationProvider = context.read<NotificationProvider>();
      final adminStatsProvider = context.read<AdminStatsProvider>();
      adminStatsProvider.setNotificationProvider(notificationProvider);
    });
  }

  Future<void> _loadWeather() async {
    setState(() {
      _loadingWeather = true;
    });

    try {
      final weather = await _weatherService.getWeather();
      setState(() {
        _weather = weather;
        _loadingWeather = false;
      });
    } catch (e) {
      setState(() {
        _loadingWeather = false;
      });
    }
  }

  final List<Widget> _pages = const [
    AdminDashboardPage(),
    AdminUsersPage(),
    AdminOrdersPage(),
    AdminProductsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 0
          ? AdminDashboardPage(
              weather: _weather,
              loadingWeather: _loadingWeather,
              onNavigateToTab: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            )
          : _pages[_currentIndex],
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
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Pengguna',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_outlined),
            activeIcon: Icon(Icons.inventory),
            label: 'Produk',
          ),
        ],
      ),
    );
  }
}

/// Dashboard page
class AdminDashboardPage extends StatefulWidget {
  final WeatherData? weather;
  final bool loadingWeather;
  final Function(int)? onNavigateToTab;

  const AdminDashboardPage({
    super.key,
    this.weather,
    this.loadingWeather = false,
    this.onNavigateToTab,
  });

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminStatsProvider>().fetchStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final statsProvider = context.watch<AdminStatsProvider>();
    final adminName = authProvider.user?.name ?? 'Admin';

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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dashboard Admin',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacingS / 2),
                              Text(
                                adminName,
                                style: AppTextStyles.h1.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.white),
                            onPressed: () async {
                              await authProvider.logout();
                              if (context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              }
                            },
                          ),
                        ],
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
              // Weather widget
              _buildWeatherWidget(widget.weather, widget.loadingWeather),

              const SizedBox(height: AppTheme.spacingL),

              // Stats cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.people,
                      label: 'Pending Users',
                      value: statsProvider.isLoading
                          ? '...'
                          : '${statsProvider.pendingUsersCount}',
                      color: AppColors.statusPending,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.shopping_cart,
                      label: 'New Orders',
                      value: statsProvider.isLoading
                          ? '...'
                          : '${statsProvider.pendingOrdersCount}',
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacingM),

              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.check_circle,
                      label: 'Completed',
                      value: statsProvider.isLoading
                          ? '...'
                          : '${statsProvider.completedOrdersCount}',
                      color: AppColors.statusApproved,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.inventory,
                      label: 'Products',
                      value: statsProvider.isLoading
                          ? '...'
                          : '${statsProvider.totalProductsCount}',
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacingL),

              // Quick actions
              Text(
                'Quick Actions',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: AppTheme.spacingM),

              _buildActionButton(
                icon: Icons.person_add,
                title: 'Approve Users',
                subtitle:
                    '${statsProvider.pendingUsersCount} pending approvals',
                onTap: () {
                  widget.onNavigateToTab?.call(1); // Navigate to Users tab
                },
              ),

              const SizedBox(height: AppTheme.spacingM),

              _buildActionButton(
                icon: Icons.add_box,
                title: 'Add Product',
                subtitle: 'Add new product to catalog',
                onTap: () {
                  widget.onNavigateToTab?.call(3); // Navigate to Products tab
                },
              ),

              const SizedBox(height: AppTheme.spacingM),

              _buildActionButton(
                icon: Icons.info_outline,
                title: 'Tentang Aplikasi',
                subtitle: 'Informasi aplikasi dan pengembang',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppTheme.spacingM),

              _buildActionButton(
                icon: Icons.analytics,
                title: 'Analytics Dashboard',
                subtitle: 'Lihat statistik dan visualisasi data',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminAnalyticsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppTheme.spacingM),

              _buildActionButton(
                icon: Icons.map_outlined,
                title: 'Peta Supplier',
                subtitle: 'Lihat lokasi supplier di peta',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SupplierMapScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppTheme.spacingM),

              _buildActionButton(
                icon: Icons.chat_bubble_outline,
                title: 'Chat dengan Client',
                subtitle: 'Lihat pesan dari client',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminChatListScreen(),
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

  Widget _buildWeatherWidget(WeatherData? weather, bool loading) {
    if (loading) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: AppTheme.spacingM),
              Text('Loading weather...', style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      );
    }

    if (weather == null) {
      return const SizedBox.shrink();
    }

    return Card(
      color: weather.isSafeForDelivery
          ? AppColors.success.withOpacity(0.1)
          : AppColors.error.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Row(
          children: [
            // Weather icon
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: weather.isSafeForDelivery
                    ? AppColors.success
                    : AppColors.error,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getWeatherIcon(weather.condition),
                size: 32,
                color: Colors.white,
              ),
            ),

            const SizedBox(width: AppTheme.spacingM),

            // Weather info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${weather.temperature.toStringAsFixed(0)}°C',
                        style: AppTextStyles.h2,
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingS,
                          vertical: AppTheme.spacingS / 2,
                        ),
                        decoration: BoxDecoration(
                          color: weather.isSafeForDelivery
                              ? AppColors.success
                              : AppColors.error,
                          borderRadius: BorderRadius.circular(AppTheme.radiusS),
                        ),
                        child: Text(
                          weather.isSafeForDelivery ? 'Aman' : 'Tunda',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    weather.description,
                    style: AppTextStyles.bodyMedium,
                  ),
                  Text(
                    weather.city,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),

            // Delivery recommendation
            Icon(
              weather.isSafeForDelivery ? Icons.check_circle : Icons.warning,
              color: weather.isSafeForDelivery
                  ? AppColors.success
                  : AppColors.error,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'rain':
      case 'drizzle':
        return Icons.water_drop;
      case 'thunderstorm':
        return Icons.thunderstorm;
      case 'snow':
        return Icons.ac_unit;
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      default:
        return Icons.wb_cloudy;
    }
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            value,
            style: AppTextStyles.h2.copyWith(color: color),
          ),
          const SizedBox(height: AppTheme.spacingS / 2),
          Text(
            label,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppTheme.spacingS),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusS),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: AppTextStyles.h4),
        subtitle: Text(subtitle, style: AppTextStyles.caption),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

/// Users page
class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UserApprovalScreen();
  }
}

/// Orders page
class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminOrdersScreen();
  }
}

/// Products page
class AdminProductsPage extends StatelessWidget {
  const AdminProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminProductsScreen();
  }
}
