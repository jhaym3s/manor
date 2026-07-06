import 'package:flutter/material.dart';
import 'package:manor/core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _isCalling = false;

  void _makeCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _showSecurityModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
            child: _isCalling ? _buildCallingState() : _buildSecurityOptions(setModalState),
          ),
        ),
      ),
    ).then((_) {
      setState(() => _isCalling = false);
    });
  }

  Widget _buildCallingState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFCBD5E1),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 40),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 500),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 1 + (value * 0.1),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.error, width: 3),
                ),
                child: const Center(
                  child: Text(
                    '📞',
                    style: TextStyle(fontSize: 40),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        const Text(
          'Calling Security...',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Connecting you now',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSecurityOptions(StateSetter setModalState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFCBD5E1),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: AppColors.errorLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.shield,
            size: 40,
            color: AppColors.error,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Contact Security',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.error,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Select an option below',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),

        _buildSecurityOption(
          '📞',
          'Call Security Post',
          false,
          () {
            setModalState(() {});
            setState(() => _isCalling = true);
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.pop(context);
              _makeCall('+2348001234567');
            });
          },
        ),
        const SizedBox(height: 10),
        _buildSecurityOption('🚨', 'Report Emergency', true, () {}),

        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityOption(String icon, String label, bool isEmergency, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isEmergency ? AppColors.errorLight : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isEmergency ? AppColors.errorBorder : AppColors.border,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isEmergency ? AppColors.error : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Security',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '24/7 estate protection',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // Main Call Button
          GestureDetector(
            onTap: _showSecurityModal,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: AppColors.errorGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error.withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.phone,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Call Security Now',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to connect immediately',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Contact Cards
          _buildContactCard(
            '🏢',
            'Security Post',
            'Main Gate • 24/7',
            '+234 800 123 4567',
            false,
          ),
          const SizedBox(height: 10),
          _buildContactCard(
            '👤',
            'Estate Manager',
            'Mr. Adeyemi',
            '+234 800 765 4321',
            false,
          ),
          const SizedBox(height: 10),
          _buildContactCard(
            '🚨',
            'Emergency',
            'Police • Fire • Ambulance',
            '112',
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    String icon,
    String title,
    String subtitle,
    String phone,
    bool isEmergency,
  ) {
    return GestureDetector(
      onTap: () => _makeCall(phone),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isEmergency ? AppColors.errorLight : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isEmergency ? Border.all(color: AppColors.errorBorder) : null,
          boxShadow: isEmergency
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                  ),
                ],
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              phone,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isEmergency ? AppColors.error : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}