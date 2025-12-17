import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tanifresh/core/theme/app_colors.dart';
import 'package:tanifresh/core/theme/app_text_styles.dart';
import 'package:tanifresh/core/theme/app_theme.dart';
import 'package:tanifresh/features/admin/orders/presentation/providers/admin_orders_provider.dart';
import 'package:tanifresh/shared/models/order_model.dart';

/// Admin orders management screen
class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminOrdersProvider>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Pesanan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<AdminOrdersProvider>().refreshOrders(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'Semua'),
                  const SizedBox(width: AppTheme.spacingS),
                  _buildFilterChip('pending', 'Pending'),
                  const SizedBox(width: AppTheme.spacingS),
                  _buildFilterChip('approved', 'Disetujui'),
                  const SizedBox(width: AppTheme.spacingS),
                  _buildFilterChip('rejected', 'Ditolak'),
                  const SizedBox(width: AppTheme.spacingS),
                  _buildFilterChip('delivered', 'Dikirim'),
                ],
              ),
            ),
          ),

          // Orders list
          Expanded(
            child: Consumer<AdminOrdersProvider>(
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
                          onPressed: () => provider.refreshOrders(),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                final orders = _selectedFilter == 'all'
                    ? provider.orders
                    : provider.getOrdersByStatus(_selectedFilter);

                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_cart_outlined,
                            size: 64, color: AppColors.textHint),
                        const SizedBox(height: AppTheme.spacingM),
                        Text(
                          'Belum ada pesanan',
                          style: AppTextStyles.h4,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    return _buildOrderCard(orders[index], provider);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildOrderCard(Order order, AdminOrdersProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: ExpansionTile(
        leading: Icon(
          Icons.shopping_bag,
          color: _getStatusColor(order.status),
        ),
        title: Text(
          'Order #${order.id.substring(0, 8)}',
          style: AppTextStyles.h4,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppTheme.spacingS / 2),
            Text(
              'Client: ${order.userId}',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppTheme.spacingS / 2),
            Text(
              _formatDate(order.createdAt),
              style: AppTextStyles.caption,
            ),
          ],
        ),
        trailing: _buildStatusBadge(order.status),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order items
                ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.productName} (${item.quantity.toInt()} ${item.unit})',
                            ),
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

                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: AppTextStyles.h4),
                    Text(
                      'Rp ${order.total.toInt()}',
                      style:
                          AppTextStyles.h3.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.spacingL),

                // Action buttons
                if (order.status == 'pending')
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _updateOrderStatus(
                              order.id, 'approved', provider),
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Setujui'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _updateOrderStatus(
                              order.id, 'rejected', provider),
                          icon: const Icon(Icons.cancel),
                          label: const Text('Tolak'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),

                if (order.status == 'approved')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _updateOrderStatus(order.id, 'delivered', provider),
                      icon: const Icon(Icons.local_shipping),
                      label: const Text('Tandai Dikirim'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.info,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
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
        label = 'Dikirim';
        break;
      default:
        color = AppColors.textSecondary;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingS,
        vertical: 4,
      ),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.statusPending;
      case 'approved':
        return AppColors.statusApproved;
      case 'rejected':
        return AppColors.statusRejected;
      case 'delivered':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _updateOrderStatus(
    String orderId,
    String newStatus,
    AdminOrdersProvider provider,
  ) async {
    final success = await provider.updateOrderStatus(orderId, newStatus);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Status pesanan berhasil diubah'
                : 'Gagal mengubah status pesanan',
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }
}
