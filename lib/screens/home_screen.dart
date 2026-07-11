import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:manor/blocs/access_codes/access_codes_bloc.dart';
import 'package:manor/blocs/auth/auth_bloc.dart';
import 'package:manor/blocs/dues/dues_bloc.dart';
import 'package:manor/core/di/injection.dart';
import 'package:manor/core/theme/app_colors.dart';
import 'package:manor/core/utils/relative_time.dart';
import 'package:manor/data/repositories/visitor_log_repository.dart';
import 'package:manor/screens/active_code_screens.dart';
import 'package:manor/screens/pending_bills.dart';
import '../models/access_code.dart';
import '../models/app_user.dart';
import '../models/bill.dart';
import '../models/visitor_log.dart';
import '../widgets/custom_bottom_sheet.dart';

class HomeScreen extends StatelessWidget {
  /// Switches the parent [MainScreen] to the Feed tab. Null-safe so the
  /// screen still builds if used standalone.
  final VoidCallback? onOpenFeed;

  const HomeScreen({super.key, this.onOpenFeed});

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthBloc, AppUser?>((bloc) => bloc.state.user);
    return MultiBlocProvider(
      providers: [
        BlocProvider<DuesBloc>(
          create: (_) {
            final bloc = getIt<DuesBloc>();
            if (user?.estateId != null && user?.householdId != null) {
              bloc.add(DuesStarted(user!.estateId!, user.householdId!));
            }
            return bloc;
          },
        ),
        BlocProvider<AccessCodesBloc>(
          create: (_) {
            final bloc = getIt<AccessCodesBloc>();
            if (user?.estateId != null && user?.householdId != null) {
              bloc.add(AccessCodesStarted(user!.estateId!, user.householdId!));
            }
            return bloc;
          },
        ),
      ],
      child: _HomeScreenContent(onOpenFeed: onOpenFeed),
    );
  }
}

class _HomeScreenContent extends StatefulWidget {
  final VoidCallback? onOpenFeed;

  const _HomeScreenContent({this.onOpenFeed});

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> {
  void _addCode(AccessCodeDraft draft) {
    context.read<AccessCodesBloc>().add(AccessCodeCreateRequested(draft));
  }

  void _deleteCode(String id) {
    context.read<AccessCodesBloc>().add(AccessCodeDeleteRequested(id));
  }

  void _payBill(String id) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Online payments are coming soon.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthBloc, AppUser?>((bloc) => bloc.state.user);
    final bills = context.watch<DuesBloc>().state.bills;
    final accessCodes = context.watch<AccessCodesBloc>().state.codes;
    final pendingBillsCount = bills.where((b) => b.status != 'paid').length;

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
                  ),
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
                  ),
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
          _buildQuickActions(context, bills, accessCodes),
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
          _buildActivityList(user, bills, accessCodes),
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

  Widget _buildQuickActions(
    BuildContext context,
    List<Bill> bills,
    List<AccessCode> accessCodes,
  ) {
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
            ),
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
            ),
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

  /// Merges dues + access codes + household-scoped visitor logs into one
  /// sorted feed — there's no dedicated activity collection in
  /// manor_admin's schema, so this is built client-side from the same
  /// live sources already backing the rest of this screen.
  Widget _buildActivityList(AppUser? user, List<Bill> bills, List<AccessCode> codes) {
    if (user?.estateId == null || user?.householdId == null) {
      return const _ActivityList(items: []);
    }

    return StreamBuilder<List<VisitorLog>>(
      stream: getIt<VisitorLogRepository>().watchVisitorLogsForHousehold(
        user!.estateId!,
        user.householdId!,
      ),
      builder: (context, snapshot) {
        final visitorLogs = snapshot.data ?? const [];
        final items = _mergeActivity(bills, codes, visitorLogs);
        return _ActivityList(items: items);
      },
    );
  }

  List<_ActivityItem> _mergeActivity(
    List<Bill> bills,
    List<AccessCode> codes,
    List<VisitorLog> visitorLogs,
  ) {
    final items = <_ActivityItem>[
      for (final bill in bills)
        if (bill.status == 'paid' && bill.paidAt != null)
          _ActivityItem(
            icon: '₦',
            color: AppColors.info,
            text: '${bill.name} paid',
            time: bill.paidAt!,
          ),
      for (final code in codes)
        if (code.createdAt != null)
          _ActivityItem(
            icon: '+',
            color: AppColors.primary,
            text: 'New code: ${code.name}',
            time: code.createdAt!,
          ),
      for (final log in visitorLogs)
        if (_visitorLogActivity(log) != null) _visitorLogActivity(log)!,
    ];

    items.sort((a, b) => b.time.compareTo(a.time));
    return items.take(5).toList();
  }

  _ActivityItem? _visitorLogActivity(VisitorLog log) {
    final time = log.displayTime;
    if (time == null) return null;

    switch (log.status) {
      case VisitorLogStatus.checkedIn:
        return _ActivityItem(icon: '✓', color: AppColors.success, text: '${log.visitorName} checked in', time: time);
      case VisitorLogStatus.checkedOut:
        return _ActivityItem(icon: '↩', color: AppColors.textSecondary, text: '${log.visitorName} checked out', time: time);
      case VisitorLogStatus.denied:
        return _ActivityItem(icon: '✕', color: AppColors.error, text: '${log.visitorName} denied entry', time: time);
      case VisitorLogStatus.expected:
        return null;
    }
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

class _ActivityItem {
  final String icon;
  final Color color;
  final String text;
  final DateTime time;

  const _ActivityItem({
    required this.icon,
    required this.color,
    required this.text,
    required this.time,
  });
}

class _ActivityList extends StatelessWidget {
  final List<_ActivityItem> items;

  const _ActivityList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'No recent activity yet.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return Column(
      children: items.map((item) {
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
                  color: item.color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    item.icon,
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
                      item.text,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      formatRelativeTime(item.time),
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
}
