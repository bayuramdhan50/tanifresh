import 'package:flutter/material.dart';
import 'package:tanifresh/core/theme/app_colors.dart';
import 'package:tanifresh/core/theme/app_text_styles.dart';
import 'package:tanifresh/core/theme/app_theme.dart';

/// Help and support screen with FAQs
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final List<FAQ> _faqs = [
    FAQ(
      question: 'Bagaimana cara memesan produk?',
      answer:
          'Anda dapat memesan produk dengan cara:\n1. Browse produk di halaman Produk\n2. Pilih produk yang diinginkan\n3. Tambahkan ke keranjang\n4. Checkout dan tunggu persetujuan admin',
    ),
    FAQ(
      question: 'Berapa lama pesanan saya diproses?',
      answer:
          'Pesanan Anda akan diproses oleh admin dalam waktu 1x24 jam. Anda akan mendapatkan notifikasi ketika pesanan disetujui atau ditolak.',
    ),
    FAQ(
      question: 'Metode pembayaran apa saja yang tersedia?',
      answer:
          'Saat ini, pembayaran dilakukan secara cash on delivery (COD). Metode pembayaran lainnya akan segera tersedia.',
    ),
    FAQ(
      question: 'Bagaimana cara mengubah alamat pengiriman?',
      answer:
          'Anda dapat mengubah alamat pengiriman melalui menu Profil > Alamat Pengiriman. Di sana Anda dapat menambah, mengedit, atau menghapus alamat.',
    ),
    FAQ(
      question: 'Apakah saya bisa membatalkan pesanan?',
      answer:
          'Pesanan yang masih berstatus "Pending" dapat dibatalkan dengan menghubungi customer service. Pesanan yang sudah disetujui tidak dapat dibatalkan.',
    ),
    FAQ(
      question: 'Bagaimana cara tracking pesanan saya?',
      answer:
          'Anda dapat melihat status pesanan Anda di halaman Pesanan. Update status akan dikirimkan melalui notifikasi.',
    ),
    FAQ(
      question: 'Apakah produk selalu tersedia?',
      answer:
          'Ketersediaan produk tergantung pada stok. Pastikan untuk memeriksa informasi stok pada detail produk sebelum memesan.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bantuan'),
      ),
      body: ListView(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Column(
              children: [
                Icon(
                  Icons.help_outline,
                  size: 64,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  'Pusat Bantuan',
                  style: AppTextStyles.h2.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  'Temukan jawaban untuk pertanyaan Anda',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Contact Support
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: Column(
                  children: [
                    Icon(
                      Icons.support_agent,
                      size: 48,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    Text(
                      'Hubungi Customer Service',
                      style: AppTextStyles.h4,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      'Kami siap membantu Anda',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spacingL),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Membuka WhatsApp...'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.chat),
                            label: const Text('WhatsApp'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.success,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppTheme.spacingM,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingM),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Membuka email...'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.email),
                            label: const Text('Email'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppTheme.spacingM,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // FAQ Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
            child: Text(
              'Pertanyaan yang Sering Diajukan (FAQ)',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),

          // FAQ List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
            itemCount: _faqs.length,
            itemBuilder: (context, index) {
              return _FAQItem(faq: _faqs[index]);
            },
          ),

          const SizedBox(height: AppTheme.spacingXl),

          // App Info
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              children: [
                Text(
                  'TaniFresh',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS / 2),
                Text(
                  'Versi 1.0.0',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  '© 2024 TaniFresh. All rights reserved.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// FAQ Item Widget with expansion
class _FAQItem extends StatefulWidget {
  final FAQ faq;

  const _FAQItem({required this.faq});

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.faq.question,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.primary,
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  widget.faq.answer,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// FAQ model
class FAQ {
  final String question;
  final String answer;

  FAQ({
    required this.question,
    required this.answer,
  });
}
