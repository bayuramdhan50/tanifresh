import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tanifresh/core/theme/app_colors.dart';
import 'package:tanifresh/core/theme/app_text_styles.dart';
import 'package:tanifresh/core/theme/app_theme.dart';

/// About Application Screen
/// Displays app information, developer details, and YouTube demo link
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // YouTube demo URL
  static const String youtubeUrl =
      'https://youtu.be/j2TiVELO6L0?si=uxBI43FcC1Fvwdwo';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // App Logo & Name
            _buildAppHeader(),
            const SizedBox(height: AppTheme.spacingXl),

            // App Description
            _buildDescriptionCard(),
            const SizedBox(height: AppTheme.spacingL),

            // Developers Section
            _buildDevelopersSection(),
            const SizedBox(height: AppTheme.spacingL),

            // Features Section
            _buildFeaturesCard(),
            const SizedBox(height: AppTheme.spacingL),

            // Tech Stack Section
            _buildTechStackCard(),
            const SizedBox(height: AppTheme.spacingL),

            // YouTube Demo Button
            _buildYouTubeButton(context),
            const SizedBox(height: AppTheme.spacingL),

            // Version Info
            _buildVersionInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXl),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.eco,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'TaniFresh',
            style: AppTextStyles.display1.copyWith(
              color: Colors.white,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Marketplace Bahan Baku Segar',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary),
                const SizedBox(width: AppTheme.spacingS),
                Text('Deskripsi Aplikasi', style: AppTextStyles.h3),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'TaniFresh adalah platform marketplace B2B yang menghubungkan restoran dengan petani dan supplier bahan baku segar. Aplikasi ini memfasilitasi transaksi perdagangan dengan sistem approval, tracking pesanan, dan perhitungan harga otomatis.',
              style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'Fitur unggulan meliputi sistem role-based access (Client & Admin), integrasi API cuaca untuk monitoring pengiriman, serta perhitungan diskon dan pajak otomatis.',
              style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevelopersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppTheme.spacingS),
          child: Row(
            children: [
              Icon(Icons.people_outline, color: AppColors.primary),
              const SizedBox(width: AppTheme.spacingS),
              Text('Tim Pengembang', style: AppTextStyles.h3),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        _buildDeveloperCard(
          name: 'Fadhlan Rahman Permana',
          npm: '152021032',
          role: 'Developer',
          color: AppColors.primary,
        ),
        const SizedBox(height: AppTheme.spacingM),
        _buildDeveloperCard(
          name: 'Wibi Ataya Sani',
          npm: '152022063',
          role: 'Developer',
          color: AppColors.accent,
        ),
      ],
    );
  }

  Widget _buildDeveloperCard({
    required String name,
    required String npm,
    required String role,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        side: BorderSide(color: color.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.h4.copyWith(
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'NPM: $npm',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    role,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
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

  Widget _buildFeaturesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star_outline, color: AppColors.accent),
                const SizedBox(width: AppTheme.spacingS),
                Text('Fitur Utama', style: AppTextStyles.h3),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            _buildFeatureItem(
              icon: Icons.shopping_cart,
              title: 'Sistem Pemesanan',
              description: 'Katalog produk, keranjang, dan checkout otomatis',
            ),
            _buildFeatureItem(
              icon: Icons.verified_user,
              title: 'Approval System',
              description: 'User baru harus disetujui admin sebelum login',
            ),
            _buildFeatureItem(
              icon: Icons.discount,
              title: 'Perhitungan Otomatis',
              description: 'Diskon, pajak, dan total harga otomatis',
            ),
            _buildFeatureItem(
              icon: Icons.cloud,
              title: 'Integrasi API Cuaca',
              description: 'Monitoring cuaca untuk rekomendasi pengiriman',
            ),
            _buildFeatureItem(
              icon: Icons.track_changes,
              title: 'Order Tracking',
              description: 'Pelacakan status pesanan real-time',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechStackCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.code, color: AppColors.primary),
                const SizedBox(width: AppTheme.spacingS),
                Text('Tech Stack', style: AppTextStyles.h3),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            _buildTechItem('Flutter 3.x', 'Mobile Framework'),
            _buildTechItem('Node.js + Express', 'Backend API'),
            _buildTechItem('MySQL', 'Database'),
            _buildTechItem('Provider', 'State Management'),
            _buildTechItem('JWT', 'Authentication'),
            _buildTechItem('OpenWeather API', 'Weather Integration'),
          ],
        ),
      ),
    );
  }

  Widget _buildTechItem(String tech, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodyMedium,
                children: [
                  TextSpan(
                    text: tech,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: ' - $description',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYouTubeButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _launchYouTube(context),
      icon: const Icon(Icons.play_circle_outline, size: 28),
      label: const Text(
        'Lihat Demo Aplikasi',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF0000), // YouTube red
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          vertical: AppTheme.spacingL,
          horizontal: AppTheme.spacingXl,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        elevation: 4,
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Center(
      child: Column(
        children: [
          Text(
            'Version 1.0.0',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '© 2024 TaniFresh Team',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchYouTube(BuildContext context) async {
    final Uri url = Uri.parse(youtubeUrl);

    try {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak dapat membuka YouTube: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
