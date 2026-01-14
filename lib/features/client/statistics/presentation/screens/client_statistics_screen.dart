import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tanifresh/core/theme/app_colors.dart';
import 'package:tanifresh/core/theme/app_text_styles.dart';
import 'package:tanifresh/core/theme/app_theme.dart';
import 'package:tanifresh/core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Client Statistics Screen with Charts
class ClientStatisticsScreen extends StatefulWidget {
  const ClientStatisticsScreen({super.key});

  @override
  State<ClientStatisticsScreen> createState() => _ClientStatisticsScreenState();
}

class _ClientStatisticsScreenState extends State<ClientStatisticsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _statisticsData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Debug logging
      print('🔍 Statistics Request:');
      print('   Token: ${token?.substring(0, 20)}...');
      print('   URL: ${ApiConstants.baseUrl}/client/statistics');

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/client/statistics'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _statisticsData = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        final responseBody = response.body;
        setState(() {
          _error =
              'Gagal memuat data statistik\nStatus: ${response.statusCode}\nResponse: $responseBody';
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
        title: const Text('Statistik Saya'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
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
                        onPressed: _loadStatistics,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadStatistics,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppTheme.spacingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: AppTheme.spacingXl),

                        // Monthly Spending Chart
                        _buildSpendingChart(),
                        const SizedBox(height: AppTheme.spacingXl),

                        // Orders by Status Bar Chart
                        _buildStatusBarChart(),
                        const SizedBox(height: AppTheme.spacingXl),

                        // Top Products Table
                        _buildTopPurchasesTable(),
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
            child: const Icon(Icons.trending_up,
                color: AppColors.primary, size: 32),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statistik Pembelian',
                  style: AppTextStyles.h2.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Riwayat 6 bulan terakhir',
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

  Widget _buildSpendingChart() {
    final monthlyData = _statisticsData?['monthlyOrders'] as List? ?? [];

    if (monthlyData.isEmpty) {
      return _buildEmptyCard('Belum ada riwayat pembelian');
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
                const Icon(Icons.attach_money, color: AppColors.primary),
                const SizedBox(width: AppTheme.spacingS),
                Text('Pengeluaran Bulanan', style: AppTextStyles.h3),
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
                            final monthName = month.substring(5);
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
                          _parseDouble(monthlyData[index]['total_spent']),
                        ),
                      ),
                      isCurved: true,
                      color: AppColors.accent,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: AppColors.accent,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.accent.withOpacity(0.1),
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

  Widget _buildStatusBarChart() {
    final statusData = _statisticsData?['statusCounts'] as List? ?? [];

    if (statusData.isEmpty) {
      return _buildEmptyCard('Belum ada data pesanan');
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
                const Icon(Icons.bar_chart, color: AppColors.accent),
                const SizedBox(width: AppTheme.spacingS),
                Text('Status Pesanan', style: AppTextStyles.h3),
              ],
            ),
            const SizedBox(height: AppTheme.spacingL),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (statusData
                          .map((e) => (e['count'] as num).toDouble())
                          .reduce((a, b) => a > b ? a : b) *
                      1.2),
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: AppTextStyles.bodySmall,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < statusData.length) {
                            final status =
                                statusData[value.toInt()]['status'] as String;
                            return Text(
                              _getStatusLabel(status),
                              style: AppTextStyles.bodySmall,
                            );
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
                  barGroups: List.generate(
                    statusData.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: (statusData[index]['count'] as num).toDouble(),
                          color: _getStatusColor(
                              statusData[index]['status'] as String),
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPurchasesTable() {
    final topProducts = _statisticsData?['topProducts'] as List? ?? [];

    if (topProducts.isEmpty) {
      return _buildEmptyCard('Belum ada riwayat pembelian produk');
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
                const Icon(Icons.shopping_basket, color: AppColors.accent),
                const SizedBox(width: AppTheme.spacingS),
                Text('Top 5 Produk Favorit', style: AppTextStyles.h3),
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
                1: FlexColumnWidth(2.5),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                  decoration:
                      BoxDecoration(color: AppColors.primary.withOpacity(0.1)),
                  children: [
                    _buildTableHeader('#'),
                    _buildTableHeader('Produk'),
                    _buildTableHeader('Qty'),
                    _buildTableHeader('Total'),
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
                      _buildTableCell(
                          'Rp ${(product['total_spent'] as num).toInt()}'),
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
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
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
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'delivered':
        return 'Done';
      default:
        return status;
    }
  }
}
