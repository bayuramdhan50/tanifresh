import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tanifresh/core/theme/app_colors.dart';
import 'package:tanifresh/core/theme/app_text_styles.dart';
import 'package:tanifresh/core/theme/app_theme.dart';
import 'package:tanifresh/core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Admin Analytics Screen with Charts and Tables
class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _analyticsData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Debug logging
      print('🔍 Analytics Request:');
      print('   Token: ${token?.substring(0, 20)}...');
      print('   URL: ${ApiConstants.baseUrl}/admin/analytics');

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/admin/analytics'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _analyticsData = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        final responseBody = response.body;
        setState(() {
          _error =
              'Gagal memuat data analytics\nStatus: ${response.statusCode}\nResponse: $responseBody';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(_error!, style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadAnalytics,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadAnalytics,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppTheme.spacingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: AppTheme.spacingXl),

                        // Monthly Revenue Chart
                        _buildRevenueChart(),
                        const SizedBox(height: AppTheme.spacingXl),

                        // Orders by Status Pie Chart
                        _buildStatusPieChart(),
                        const SizedBox(height: AppTheme.spacingXl),

                        // Top Products Table
                        _buildTopProductsTable(),
                        const SizedBox(height: AppTheme.spacingL),
                      ],
                    ),
                  ),
                ),
    );
  }

  // Helper function to safely parse numeric values from MySQL
  double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.analytics, color: AppColors.primary, size: 32),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analytics Dashboard',
                  style: AppTextStyles.h2.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Visualisasi data 6 bulan terakhir',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    final monthlyData = _analyticsData?['monthlyOrders'] as List? ?? [];

    if (monthlyData.isEmpty) {
      return _buildEmptyCard('Belum ada data transaksi bulanan');
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, color: AppColors.primary),
                const SizedBox(width: AppTheme.spacingS),
                Text('Revenue Bulanan', style: AppTextStyles.h3),
              ],
            ),
            const SizedBox(height: AppTheme.spacingL),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppColors.border.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            'Rp ${(value / 1000).toStringAsFixed(0)}k',
                            style: AppTextStyles.bodySmall,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < monthlyData.length) {
                            final month =
                                monthlyData[value.toInt()]['month'] as String;
                            final monthName =
                                month.substring(5); // Get MM from YYYY-MM
                            return Text(monthName,
                                style: AppTextStyles.bodySmall);
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        monthlyData.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          _parseDouble(monthlyData[index]['revenue']),
                        ),
                      ),
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: AppColors.primary,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPieChart() {
    final statusData = _analyticsData?['statusCounts'] as List? ?? [];

    if (statusData.isEmpty) {
      return _buildEmptyCard('Belum ada data status pesanan');
    }

    final totalOrders = statusData.fold<int>(
      0,
      (sum, item) => sum + ((item['count'] as num?)?.toInt() ?? 0),
    );

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pie_chart, color: AppColors.accent),
                const SizedBox(width: AppTheme.spacingS),
                Text('Distribusi Status Pesanan', style: AppTextStyles.h3),
              ],
            ),
            const SizedBox(height: AppTheme.spacingL),
            SizedBox(
              height: 250,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: List.generate(statusData.length, (index) {
                          final item = statusData[index];
                          final count = (item['count'] as num?)?.toInt() ?? 0;
                          final percentage =
                              (count / totalOrders * 100).toStringAsFixed(1);

                          return PieChartSectionData(
                            value: count.toDouble(),
                            title: '$percentage%',
                            color: _getStatusColor(item['status'] as String),
                            radius: 100,
                            titleStyle: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }),
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingL),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: statusData.map((item) {
                        final status = item['status'] as String;
                        final count = (item['count'] as num?)?.toInt() ?? 0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _getStatusLabel(status),
                                  style: AppTextStyles.bodySmall,
                                ),
                              ),
                              Text(
                                '$count',
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProductsTable() {
    final topProducts = _analyticsData?['topProducts'] as List? ?? [];

    if (topProducts.isEmpty) {
      return _buildEmptyCard('Belum ada data produk terlaris');
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: AppColors.accent),
                const SizedBox(width: AppTheme.spacingS),
                Text('Top 5 Produk Terlaris', style: AppTextStyles.h3),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            Table(
              border: TableBorder.all(
                color: AppColors.border.withOpacity(0.3),
                width: 1,
              ),
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration:
                      BoxDecoration(color: AppColors.primary.withOpacity(0.1)),
                  children: [
                    _buildTableHeader('#'),
                    _buildTableHeader('Produk'),
                    _buildTableHeader('Total Qty'),
                    _buildTableHeader('Orders'),
                  ],
                ),
                ...topProducts.asMap().entries.map((entry) {
                  final index = entry.key;
                  final product = entry.value;
                  return TableRow(
                    children: [
                      _buildTableCell('${index + 1}'),
                      _buildTableCell(product['product_name'] as String),
                      _buildTableCell('${product['total_quantity']}'),
                      _buildTableCell('${product['order_count']}'),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: AppTextStyles.bodySmall,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.bar_chart, size: 48, color: AppColors.textHint),
              const SizedBox(height: AppTheme.spacingM),
              Text(
                message,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
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

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      case 'delivered':
        return 'Selesai';
      default:
        return status;
    }
  }
}
