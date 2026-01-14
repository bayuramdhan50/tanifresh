import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/buttons/custom_button.dart';
import '../../../../shared/widgets/inputs/custom_text_field.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';
import '../../../admin/dashboard/presentation/screens/admin_dashboard_screen.dart';
import '../../../client/home/presentation/screens/client_home_screen.dart';

/// Login screen with modern gradient design
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      // Navigate based on user role
      if (authProvider.isAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminDashboardScreen(),
          ),
        );
      } else if (authProvider.isClient) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ClientHomeScreen(),
          ),
        );
      }
    } else {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Login gagal'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Gradient header with logo
              Container(
                width: size.width,
                height: size.height * 0.35,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(AppTheme.radiusXl),
                    bottomRight: Radius.circular(AppTheme.radiusXl),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo/Icon
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingL),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.eco,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    Text(
                      'TatanenFresh',
                      style: AppTextStyles.display1.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      'Marketplace Bahan Baku Segar',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingXl),

              // Login form
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat Datang',
                        style: AppTextStyles.h1,
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      Text(
                        'Masuk ke akun Anda untuk melanjutkan',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXl),

                      // Email field
                      CustomTextField(
                        label: 'Email',
                        hintText: 'Masukkan email Anda',
                        controller: _emailController,
                        validator: Validators.validateEmail,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                      ),

                      const SizedBox(height: AppTheme.spacingM),

                      // Password field
                      CustomTextField(
                        label: 'Password',
                        hintText: 'Masukkan password Anda',
                        controller: _passwordController,
                        validator: Validators.validatePassword,
                        obscureText: true,
                        prefixIcon: Icons.lock_outline,
                      ),

                      const SizedBox(height: AppTheme.spacingM),

                      // Remember me checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                            activeColor: AppColors.primary,
                          ),
                          Text(
                            'Ingat saya',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),

                      const SizedBox(height: AppTheme.spacingL),

                      // Login button
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return CustomButton(
                            text: 'Masuk',
                            onPressed:
                                authProvider.isLoading ? null : _handleLogin,
                            isLoading: authProvider.isLoading,
                            icon: Icons.login,
                          );
                        },
                      ),

                      const SizedBox(height: AppTheme.spacingL),

                      // Register link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Belum punya akun? ',
                            style: AppTextStyles.bodyMedium,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Daftar Sekarang',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppTheme.spacingL),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
