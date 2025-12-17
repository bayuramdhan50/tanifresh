import 'package:flutter/material.dart';
import 'package:tanifresh/core/theme/app_colors.dart';
import 'package:tanifresh/core/theme/app_text_styles.dart';
import 'package:tanifresh/core/theme/app_theme.dart';
import 'package:tanifresh/core/network/api_client.dart';
import 'package:tanifresh/core/constants/api_constants.dart';
import 'package:tanifresh/core/utils/formatters.dart';
import '../../../../../shared/widgets/loading/loading_indicator.dart';

/// User approval management screen for admin
class UserApprovalScreen extends StatefulWidget {
  const UserApprovalScreen({super.key});

  @override
  State<UserApprovalScreen> createState() => _UserApprovalScreenState();
}

class _UserApprovalScreenState extends State<UserApprovalScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;
  List<dynamic> _pendingUsers = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPendingUsers();
  }

  Future<void> _loadPendingUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiClient.get(ApiConstants.pendingUsers);
      setState(() {
        _pendingUsers = response.data['users'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _approveUser(String userId, String userName) async {
    try {
      await _apiClient.put(ApiConstants.approveUser(userId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$userName berhasil disetujui'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadPendingUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyetujui: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _rejectUser(String userId, String userName) async {
    try {
      await _apiClient.delete(ApiConstants.rejectUser(userId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$userName ditolak'),
            backgroundColor: AppColors.warning,
          ),
        );
        _loadPendingUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menolak: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Persetujuan Pengguna'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingUsers,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Memuat data...')
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      Text('Error: $_error', style: AppTextStyles.bodyMedium),
                      const SizedBox(height: AppTheme.spacingL),
                      ElevatedButton(
                        onPressed: _loadPendingUsers,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : _pendingUsers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: AppColors.success,
                          ),
                          const SizedBox(height: AppTheme.spacingM),
                          Text(
                            'Tidak ada pengguna pending',
                            style: AppTextStyles.h4,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppTheme.spacingM),
                      itemCount: _pendingUsers.length,
                      itemBuilder: (context, index) {
                        final user = _pendingUsers[index];
                        return _UserCard(
                          user: user,
                          onApprove: () =>
                              _approveUser(user['id'], user['name']),
                          onReject: () => _rejectUser(user['id'], user['name']),
                        );
                      },
                    ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final dynamic user;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _UserCard({
    required this.user,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    user['role'] == 'admin'
                        ? Icons.agriculture
                        : Icons.restaurant,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name'] ?? 'Unknown',
                        style: AppTextStyles.h4,
                      ),
                      const SizedBox(height: AppTheme.spacingS / 2),
                      Text(
                        user['email'] ?? '',
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: AppTheme.spacingS / 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingS,
                          vertical: AppTheme.spacingS / 2,
                        ),
                        decoration: BoxDecoration(
                          color: user['role'] == 'admin'
                              ? AppColors.accent.withOpacity(0.1)
                              : AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusS),
                        ),
                        child: Text(
                          user['role'] == 'admin' ? 'Petani' : 'Restoran',
                          style: AppTextStyles.caption.copyWith(
                            color: user['role'] == 'admin'
                                ? AppColors.accent
                                : AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (user['phone'] != null || user['address'] != null) ...[
              const SizedBox(height: AppTheme.spacingM),
              const Divider(),
              const SizedBox(height: AppTheme.spacingM),
            ],
            if (user['phone'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
                child: Row(
                  children: [
                    const Icon(Icons.phone,
                        size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: AppTheme.spacingS),
                    Text(
                      Formatters.formatPhoneNumber(user['phone']),
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            if (user['address'] != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on,
                      size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: AppTheme.spacingS),
                  Expanded(
                    child: Text(
                      user['address'],
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: AppTheme.spacingL),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Tolak Pengguna?'),
                          content: Text('Yakin ingin menolak ${user['name']}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Batal'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                onReject();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                              ),
                              child: const Text('Tolak'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Tolak'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Setujui Pengguna?'),
                          content:
                              Text('Yakin ingin menyetujui ${user['name']}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Batal'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                onApprove();
                              },
                              child: const Text('Setujui'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Setujui'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
