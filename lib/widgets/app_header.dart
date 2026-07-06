import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:manor/blocs/auth/auth_bloc.dart';
import 'package:manor/core/theme/app_colors.dart';

class AppHeader extends StatelessWidget {
  final VoidCallback? onNotificationTap;

  const AppHeader({super.key, this.onNotificationTap});

  String _initials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return '$first$last'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final fullName = context.select<AuthBloc, String>(
      (bloc) => bloc.state.user?.fullName ?? 'Resident',
    );

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.push('/profile'),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              _initials(fullName),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          Text(
                            fullName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: onNotificationTap ??
                        () => context.push('/notifications'),
                    child: Stack(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColors.warning,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.home_outlined, size: 14, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      '40 UDI',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
