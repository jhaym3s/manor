import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:manor/core/theme/app_colors.dart';
import 'package:manor/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../blocs/auth/auth_bloc.dart';

/// Landing screen for the security/gateman role. Large icon-first tiles
/// instead of a bottom-nav bar — fewer things to read, nothing to learn
/// about tab semantics, each destination is a single big obvious tap.
class SecurityHomeScreen extends StatelessWidget {
  const SecurityHomeScreen({super.key});

  Future<void> _callSecurityPost() async {
    final uri = Uri(scheme: 'tel', path: '+2348001234567');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final guardName = context.select<AuthBloc, String>(
      (bloc) => bloc.state.user?.fullName ?? 'Guard',
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppColors.headerGradient),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.shield,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Security Team',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          Text(
                            guardName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.read<AuthBloc>().add(
                        const AuthLogoutRequested(),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Log Out',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _BigTile(
                    icon: Icons.qr_code_scanner,
                    label: 'Verify Visitor',
                    subtitle: 'Check a visitor\'s gate code',
                    gradient: AppColors.primaryGradient,
                    onTap: () => context.push('/security/verify'),
                  ),
                  const SizedBox(height: 16),
                  _BigTile(
                    icon: Icons.history,
                    label: 'Visitor Log',
                    subtitle: 'See recent gate activity',
                    gradient: AppColors.purpleGradient,
                    onTap: () => context.push('/security/log'),
                  ),
                  const SizedBox(height: 16),
                  _BigTile(
                    icon: Icons.warning_amber_rounded,
                    label: 'Emergency',
                    subtitle: 'Call the security post now',
                    gradient: AppColors.errorGradient,
                    onTap: _callSecurityPost,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BigTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  const _BigTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.cardRadiusLarge),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}
