import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tanifresh/core/theme/app_colors.dart';
import 'package:tanifresh/core/theme/app_text_styles.dart';
import 'package:tanifresh/core/theme/app_theme.dart';
import 'package:tanifresh/features/auth/presentation/providers/auth_provider.dart';
import 'package:tanifresh/shared/providers/notification_provider.dart';

/// Settings screen for app and account preferences
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'id';

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final notificationProvider = context.watch<NotificationProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        children: [
          // Account Section
          _buildSectionHeader('Akun'),
          _buildAccountInfo(
            icon: Icons.person_outline,
            label: 'Nama',
            value: user?.name ?? '-',
          ),
          _buildAccountInfo(
            icon: Icons.email_outlined,
            label: 'Email',
            value: user?.email ?? '-',
          ),
          _buildAccountInfo(
            icon: Icons.badge_outlined,
            label: 'Role',
            value: user?.role.toUpperCase() ?? '-',
          ),

          const Divider(height: AppTheme.spacingXl),

          // Notifications Section
          _buildSectionHeader('Notifikasi'),
          _buildSwitchTile(
            icon: Icons.notifications_outlined,
            title: 'Notifikasi Push',
            subtitle: 'Aktifkan notifikasi untuk aplikasi',
            value: notificationProvider.notificationsEnabled,
            onChanged: (value) {
              notificationProvider.toggleNotifications(value);
            },
          ),
          _buildSwitchTile(
            icon: Icons.shopping_bag_outlined,
            title: 'Notifikasi Pesanan',
            subtitle: 'Update status pesanan Anda',
            value: notificationProvider.orderNotifications,
            onChanged: notificationProvider.notificationsEnabled
                ? (value) {
                    notificationProvider.toggleOrderNotifications(value);
                  }
                : null,
          ),
          _buildSwitchTile(
            icon: Icons.local_offer_outlined,
            title: 'Notifikasi Promosi',
            subtitle: 'Dapatkan info promo dan diskon',
            value: notificationProvider.promotionNotifications,
            onChanged: notificationProvider.notificationsEnabled
                ? (value) {
                    notificationProvider.togglePromotionNotifications(value);
                  }
                : null,
          ),

          const Divider(height: AppTheme.spacingXl),

          // App Preferences
          _buildSectionHeader('Preferensi Aplikasi'),
          _buildListTile(
            icon: Icons.language_outlined,
            title: 'Bahasa',
            subtitle:
                _selectedLanguage == 'id' ? 'Bahasa Indonesia' : 'English',
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguageDialog(),
          ),
          _buildListTile(
            icon: Icons.palette_outlined,
            title: 'Tema',
            subtitle: 'Terang',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pengaturan tema akan segera hadir'),
                ),
              );
            },
          ),

          const Divider(height: AppTheme.spacingXl),

          // About Section
          _buildSectionHeader('Tentang'),
          _buildListTile(
            icon: Icons.info_outline,
            title: 'Versi Aplikasi',
            subtitle: '1.0.0',
            onTap: null,
          ),
          _buildListTile(
            icon: Icons.description_outlined,
            title: 'Syarat dan Ketentuan',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showInfoDialog(
                'Syarat dan Ketentuan',
                'Dengan menggunakan aplikasi TaniFresh, Anda setuju dengan syarat dan ketentuan yang berlaku.\n\n'
                    '1. Pengguna bertanggung jawab atas keakuratan informasi yang diberikan\n'
                    '2. Pembayaran dilakukan sesuai dengan metode yang tersedia\n'
                    '3. Pesanan yang sudah disetujui tidak dapat dibatalkan\n'
                    '4. Harga produk dapat berubah sewaktu-waktu',
              );
            },
          ),
          _buildListTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Kebijakan Privasi',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showInfoDialog(
                'Kebijakan Privasi',
                'TaniFresh menghargai privasi Anda. Kami mengumpulkan dan menggunakan data Anda untuk:\n\n'
                    '1. Memproses pesanan dan transaksi\n'
                    '2. Meningkatkan layanan aplikasi\n'
                    '3. Mengirimkan notifikasi terkait pesanan\n'
                    '4. Komunikasi promosi (dengan persetujuan Anda)\n\n'
                    'Data Anda tidak akan dibagikan kepada pihak ketiga tanpa persetujuan Anda.',
              );
            },
          ),

          const SizedBox(height: AppTheme.spacingXl),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingL,
        AppTheme.spacingL,
        AppTheme.spacingL,
        AppTheme.spacingM,
      ),
      child: Text(
        title,
        style: AppTextStyles.h4.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAccountInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: AppTextStyles.bodySmall),
      subtitle:
          Text(value, style: AppTextStyles.bodyMedium.copyWith(height: 1.5)),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool)? onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(
        icon,
        color: onChanged == null ? AppColors.textHint : AppColors.primary,
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
      enabled: onTap != null,
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Bahasa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Bahasa Indonesia'),
              value: 'id',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bahasa berhasil diubah')),
                );
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Language changed successfully')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: AppTextStyles.bodyMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
