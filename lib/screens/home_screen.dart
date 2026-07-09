import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manor/core/theme/app_colors.dart';
import 'package:manor/screens/active_code_screens.dart';
import 'package:manor/screens/pending_bills.dart';
import '../models/access_code.dart';
import '../models/bill.dart';
import '../widgets/custom_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  /// Switches the parent [MainScreen] to the Feed tab. Null-safe so the
  /// screen still builds if used standalone.
  final VoidCallback? onOpenFeed;

  const HomeScreen({super.key, this.onOpenFeed});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<AccessCode> accessCodes = AccessCode.getSampleCodes();
  List<Bill> bills = Bill.getSampleBills();

  void _addCode(AccessCode code) {
    setState(() => accessCodes.add(code));
  }

  void _deleteCode(int id) {
    setState(() => accessCodes.removeWhere((c) => c.id == id));
  }

  void _payBill(int id) {
    setState(() {
      final index = bills.indexWhere((b) => b.id == id);
      if (index != -1) {
        bills[index] = bills[index].copyWith(status: 'paid');
      }
    });
  }

  int get pendingBillsCount => bills.where((b) => b.status != 'paid').length;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emergency Banner
          _buildEmergencyBanner(context),
          const SizedBox(height: 20),

          // Quick Stats - Tappable cards
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActiveCodesScreen(
                        codes: accessCodes,
                        onAddCode: _addCode,
                        onDeleteCode: _deleteCode,
                      ),
                    ),
                  ).then((_) => setState(() {})),
                  child: _buildStatCard(
                    '🔐',
                    '${accessCodes.length}',
                    'Active Codes',
                    subtitle: 'Tap to manage',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PendingBillsScreen(
                        bills: bills,
                        onPayBill: _payBill,
                      ),
                    ),
                  ).then((_) => setState(() {})),
                  child: _buildStatCard(
                    '📋',
                    '$pendingBillsCount',
                    'Pending Bills',
                    isWarning: pendingBillsCount > 0,
                    subtitle: 'Tap to pay',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildQuickActions(context),
          const SizedBox(height: 24),

          // Recent Activity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'See all',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildActivityList(),
        ],
      ),
    );
  }

  Widget _buildEmergencyBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSecurityModal(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.errorLight, Color(0xFFFEE2E2)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.errorBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppColors.errorGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.shield,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emergency?',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF991B1B),
                    ),
                  ),
                  Text(
                    'Tap to call security',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFFB91C1C),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFB91C1C),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String icon,
    String value,
    String label, {
    bool isWarning = false,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isWarning
            ? const LinearGradient(colors: [AppColors.warningLight, AppColors.warningBorder])
            : null,
        color: isWarning ? null : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isWarning
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.textTertiary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.primary.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ActiveCodesScreen(
                  codes: accessCodes,
                  onAddCode: _addCode,
                  onDeleteCode: _deleteCode,
                ),
              ),
            ).then((_) => setState(() {})),
            child: _buildQuickActionItem(
              Icons.lock,
              'New Code',
              AppColors.primaryGradient,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PendingBillsScreen(
                  bills: bills,
                  onPayBill: _payBill,
                ),
              ),
            ).then((_) => setState(() {})),
            child: _buildQuickActionItem(
              Icons.credit_card,
              'Pay Bills',
              AppColors.primaryGradient,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: widget.onOpenFeed,
            behavior: HitTestBehavior.opaque,
            child: _buildQuickActionItem(
              Icons.chat_bubble,
              'Feed',
              AppColors.purpleGradient,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => _showSecurityModal(context),
            child: _buildQuickActionItem(
              Icons.phone,
              'Security',
              AppColors.errorGradient,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionItem(IconData icon, String label, LinearGradient gradient) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    final activities = [
      {'text': 'Family code used at gate', 'time': '2h ago', 'icon': '✓', 'color': AppColors.success},
      {'text': 'New code: Cleaner', 'time': 'Yesterday', 'icon': '+', 'color': AppColors.primary},
      {'text': 'Security levy paid', 'time': '3 days ago', 'icon': '₦', 'color': AppColors.info},
    ];

    return Column(
      children: activities.map((activity) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: activity['color'] as Color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    activity['icon'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['text'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      activity['time'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showSecurityModal(BuildContext context) {
    CustomBottomSheet.show(
      context: context,
      title: 'Contact Security',
      subtitle: 'Select an option below',
      titleColor: AppColors.error,
      child: Column(
        children: [
          _buildSecurityOption('📞', 'Call Security Post', false, () {
            Navigator.pop(context);
          }),
          const SizedBox(height: 10),
          _buildSecurityOption('🚨', 'Report Emergency', true, () {
            Navigator.pop(context);
            context.push('/emergency');
          }),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
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
}