import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:tanifresh/core/theme/app_colors.dart';
import 'package:tanifresh/core/theme/app_text_styles.dart';
import 'package:tanifresh/core/theme/app_theme.dart';

/// Supplier Map Screen with OpenStreetMap
/// Shows supplier locations and delivery zones
class SupplierMapScreen extends StatefulWidget {
  const SupplierMapScreen({super.key});

  @override
  State<SupplierMapScreen> createState() => _SupplierMapScreenState();
}

class _SupplierMapScreenState extends State<SupplierMapScreen> {
  final MapController _mapController = MapController();

  // Sample supplier locations (Bandung area)
  final List<SupplierLocation> _suppliers = [
    SupplierLocation(
      name: 'Petani Sayur Lembang',
      address: 'Lembang, Bandung Barat',
      position: LatLng(-6.8115, 107.6172),
      category: 'Sayuran',
    ),
    SupplierLocation(
      name: 'Kebun Buah Ciwidey',
      address: 'Ciwidey, Bandung',
      position: LatLng(-7.1486, 107.4797),
      category: 'Buah-buahan',
    ),
    SupplierLocation(
      name: 'Supplier Daging Segar',
      address: 'Cimahi, Bandung',
      position: LatLng(-6.8723, 107.5425),
      category: 'Daging',
    ),
    SupplierLocation(
      name: 'Toko Bahan Pokok',
      address: 'Bandung Pusat',
      position: LatLng(-6.9175, 107.6191),
      category: 'Bahan Pokok',
    ),
  ];

  SupplierLocation? _selectedSupplier;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Supplier'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _centerMap,
          ),
        ],
      ),
      body: Stack(
        children: [
          // OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(-6.9175, 107.6191), // Bandung center
              initialZoom: 11.0,
              onTap: (_, __) => setState(() => _selectedSupplier = null),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.tanifresh.app',
              ),
              MarkerLayer(
                markers: _suppliers.map((supplier) {
                  return Marker(
                    point: supplier.position,
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSupplier = supplier;
                        });
                        _mapController.move(supplier.position, 14.0);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedSupplier == supplier
                              ? AppColors.accent
                              : AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.store,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Selected Supplier Info Card
          if (_selectedSupplier != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _buildSupplierCard(_selectedSupplier!),
            ),

          // Supplier List Button
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _showSupplierList,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.list, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierCard(SupplierLocation supplier) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Icon(
                    Icons.store,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        supplier.name,
                        style: AppTextStyles.h4.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        supplier.category,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            Row(
              children: [
                const Icon(Icons.location_on,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    supplier.address,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Navigate to supplier details or contact
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Hubungi ${supplier.name}')),
                      );
                    },
                    icon: const Icon(Icons.phone),
                    label: const Text('Hubungi'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Arahkan ke lokasi...')),
                      );
                    },
                    icon: const Icon(Icons.directions),
                    label: const Text('Arahkan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _centerMap() {
    _mapController.move(LatLng(-6.9175, 107.6191), 11.0);
    setState(() => _selectedSupplier = null);
  }

  void _showSupplierList() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Daftar Supplier', style: AppTextStyles.h3),
            const SizedBox(height: AppTheme.spacingM),
            ..._suppliers.map((supplier) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Icon(Icons.store, color: AppColors.primary),
                ),
                title: Text(supplier.name, style: AppTextStyles.bodyMedium),
                subtitle:
                    Text(supplier.category, style: AppTextStyles.bodySmall),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedSupplier = supplier);
                  _mapController.move(supplier.position, 14.0);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class SupplierLocation {
  final String name;
  final String address;
  final LatLng position;
  final String category;

  SupplierLocation({
    required this.name,
    required this.address,
    required this.position,
    required this.category,
  });
}
