import 'package:flutter/material.dart';
import 'package:tanifresh/core/theme/app_colors.dart';
import 'package:tanifresh/core/theme/app_text_styles.dart';
import 'package:tanifresh/core/theme/app_theme.dart';
import 'package:tanifresh/shared/models/order_model.dart';

/// Order detail screen
class OrderDetailScreen extends StatelessWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ID Pesanan', style: AppTextStyles.bodyMedium),
                        Text(
                          '#${order.id.substring(0, 8)}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tanggal', style: AppTextStyles.bodyMedium),
                        Text(
                          _formatDate(order.createdAt),
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Status', style: AppTextStyles.bodyMedium),
                        _buildStatusBadge(order.status),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppTheme.spacingL),

            // Order Items
            Text('Item Pesanan', style: AppTextStyles.h3),
            const SizedBox(height: AppTheme.spacingM),

            ...order.items.map((item) => Card(
                  margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
                  child: ListTile(
                    title: Text(
                      item.productName,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${item.quantity.toInt()} ${item.unit} × Rp ${item.price.toInt()}',
                      style: AppTextStyles.bodySmall,
                    ),
                    trailing: Text(
                      'Rp ${(item.price * item.quantity).toInt()}',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                )),

            const SizedBox(height: AppTheme.spacingL),

            // Price Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: Column(
                  children: [
                    _buildPriceRow('Subtotal', order.subtotal),
                    const SizedBox(height: AppTheme.spacingS),
                    _buildPriceRow('Diskon', order.discount, isDiscount: true),
                    const SizedBox(height: AppTheme.spacingS),
                    _buildPriceRow('Pajak', order.tax),
                    const Divider(height: AppTheme.spacingL),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: AppTextStyles.h3),
                        Text(
                          'Rp ${order.total.toInt()}',
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (order.notes != null && order.notes!.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingL),
              Text('Catatan', style: AppTextStyles.h3),
              const SizedBox(height: AppTheme.spacingS),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Text(order.notes!, style: AppTextStyles.bodyMedium),
                ),
              ),
            ],

            if (order.rejectionReason != null &&
                order.rejectionReason!.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingL),
              Text('Alasan Penolakan', style: AppTextStyles.h3),
              const SizedBox(height: AppTheme.spacingS),
              Card(
                color: AppColors.error.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Text(
                    order.rejectionReason!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount,
      {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(
          '${isDiscount && amount > 0 ? '- ' : ''}Rp ${amount.toInt()}',
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDiscount && amount > 0 ? AppColors.error : null,
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
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
