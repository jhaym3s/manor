import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:manor/core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

import '../blocs/auth/auth_bloc.dart';

/// Number security dispatch is reached on. Hard-coded for the prototype;
/// swap for an estate-configured value once available.
const _securityPhone = '+2348001234567';

enum EmergencyType { medical, fire, intruder, other }

extension on EmergencyType {
  String get label => switch (this) {
    EmergencyType.medical => 'Medical',
    EmergencyType.fire => 'Fire',
    EmergencyType.intruder => 'Intruder',
    EmergencyType.other => 'Other',
  };

  String get emoji => switch (this) {
    EmergencyType.medical => '🚑',
    EmergencyType.fire => '🔥',
    EmergencyType.intruder => '🚨',
    EmergencyType.other => '⚠️',
  };
}

/// Which panel of the flow is on screen.
enum _Step { pickType, confirm, dispatched }

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen>
    with SingleTickerProviderStateMixin {
  _Step _step = _Step.pickType;
  EmergencyType? _selected;

  // Drives the hold-to-confirm progress ring. Completing it fires the alert.
  late final AnimationController _holdController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..addStatusListener((status) {
    if (status == AnimationStatus.completed) _dispatch();
  });

  @override
  void dispose() {
    _holdController.dispose();
    super.dispose();
  }

  void _pickType(EmergencyType type) {
    setState(() {
      _selected = type;
      _step = _Step.confirm;
    });
  }

  void _holdStart(_) => _holdController.forward();

  void _holdEnd(_) {
    if (_holdController.status != AnimationStatus.completed) {
      _holdController.reverse();
    }
  }

  void _dispatch() {
    // No dispatch backend yet — this simulates the alert being broadcast to
    // security + estate management. Real FCM/Firestore wiring slots in here.
    setState(() => _step = _Step.dispatched);
  }

  void _backToTypes() {
    _holdController.reset();
    setState(() {
      _selected = null;
      _step = _Step.pickType;
    });
  }

  Future<void> _callSecurity() async {
    final uri = Uri(scheme: 'tel', path: _securityPhone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: switch (_step) {
              _Step.pickType => _buildTypeGrid(),
              _Step.confirm => _buildConfirm(),
              _Step.dispatched => _buildDispatched(),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.errorGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 20, 16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () {
                  if (_step == _Step.confirm) {
                    _backToTypes();
                  } else {
                    context.pop();
                  }
                },
              ),
              const Text(
                'Report Emergency',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step 1: pick the emergency type ──────────────────────────────────────
  Widget _buildTypeGrid() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What's happening?",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Choose the type so the right responders are alerted.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.05,
            children:
                EmergencyType.values.map((t) => _buildTypeCard(t)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCard(EmergencyType type) {
    return GestureDetector(
      onTap: () => _pickType(type),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(type.emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              type.label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 2: hold to confirm ───────────────────────────────────────────────
  Widget _buildConfirm() {
    final type = _selected!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          Text(type.emoji, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 12),
          Text(
            type.label,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Press and hold the button to alert security and estate '
            'management. Release to cancel.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const Spacer(),
          GestureDetector(
            onTapDown: _holdStart,
            onTapUp: _holdEnd,
            onTapCancel: () => _holdEnd(null),
            child: AnimatedBuilder(
              animation: _holdController,
              builder: (context, child) {
                final progress = _holdController.value;
                return Container(
                  height: 68,
                  decoration: BoxDecoration(
                    gradient: AppColors.errorGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.error.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Fill that grows as the resident holds.
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          progress > 0 ? 'KEEP HOLDING…' : 'HOLD TO ALERT',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _backToTypes,
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── Step 3: dispatched confirmation ───────────────────────────────────────
  Widget _buildDispatched() {
    final user = context.read<AuthBloc>().state.user;
    final name = user?.fullName ?? 'Resident';
    final unit = user?.householdId ?? 'Your unit';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) => Transform.scale(
              scale: 0.8 + value * 0.2,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 52,
                  color: AppColors.success,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Help is on the way',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Security and estate management have been alerted.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SHARED WITH SECURITY',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 12),
                _sharedRow(Icons.person_outline, name),
                const SizedBox(height: 10),
                _sharedRow(Icons.home_outlined, unit),
                const SizedBox(height: 10),
                _sharedRow(
                  Icons.warning_amber_rounded,
                  '${_selected!.emoji} ${_selected!.label} emergency',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _callSecurity,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.phone, size: 20),
              label: const Text(
                'Call Security Now',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.border, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Done',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sharedRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
