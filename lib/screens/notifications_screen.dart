import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manor/core/theme/app_colors.dart';

/// Kind of notification — drives the leading icon and its accent color so
/// each category is recognisable at a glance.
enum NotificationKind { security, access, bill, community, system }

class AppNotification {
  final int id;
  final NotificationKind kind;
  final String title;
  final String message;
  final String time;
  bool isRead;

  AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
  });

  /// Sample feed used until notifications are wired to Firestore/FCM.
  static List<AppNotification> sample() => [
    AppNotification(
      id: 1,
      kind: NotificationKind.security,
      title: 'Visitor at the gate',
      message: 'Security is holding a guest for "Cleaner" — approve or deny.',
      time: '2m ago',
    ),
    AppNotification(
      id: 2,
      kind: NotificationKind.access,
      title: 'Access code used',
      message: 'Your "Family" code was used at the Main Gate.',
      time: '1h ago',
    ),
    AppNotification(
      id: 3,
      kind: NotificationKind.bill,
      title: 'Security levy due',
      message: '₦25,000 is due on 15 Jul. Tap to pay before the deadline.',
      time: '5h ago',
    ),
    AppNotification(
      id: 4,
      kind: NotificationKind.community,
      title: 'New estate announcement',
      message: 'Management posted: "Water supply maintenance this Saturday."',
      time: 'Yesterday',
      isRead: true,
    ),
    AppNotification(
      id: 5,
      kind: NotificationKind.system,
      title: 'Welcome to Manor',
      message: 'Your resident profile is all set up. Explore the app!',
      time: '3 days ago',
      isRead: true,
    ),
  ];
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<AppNotification> _notifications = AppNotification.sample();

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllRead() {
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
  }

  void _markRead(AppNotification n) {
    if (n.isRead) return;
    setState(() => n.isRead = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _notifications.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) =>
                        _buildTile(_notifications[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 20, 20),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => context.pop(),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _unreadCount == 0
                          ? 'You\'re all caught up'
                          : '$_unreadCount unread',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              if (_unreadCount > 0)
                TextButton(
                  onPressed: _markAllRead,
                  child: const Text(
                    'Mark all read',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile(AppNotification n) {
    final accent = _accentFor(n.kind);

    return GestureDetector(
      onTap: () => _markRead(n),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: n.isRead ? AppColors.surface : accent.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: n.isRead ? AppColors.borderLight : accent.withOpacity(0.25),
          ),
          boxShadow: n.isRead
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_iconFor(n.kind), color: accent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: n.isRead
                                ? FontWeight.w600
                                : FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (!n.isRead)
                        Container(
                          width: 9,
                          height: 9,
                          margin: const EdgeInsets.only(left: 8, top: 4),
                          decoration: BoxDecoration(
                            color: accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.message,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    n.time,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              size: 40,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "We'll let you know when something happens.",
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(NotificationKind kind) {
    switch (kind) {
      case NotificationKind.security:
        return Icons.shield_outlined;
      case NotificationKind.access:
        return Icons.lock_outlined;
      case NotificationKind.bill:
        return Icons.credit_card_outlined;
      case NotificationKind.community:
        return Icons.campaign_outlined;
      case NotificationKind.system:
        return Icons.info_outline;
    }
  }

  Color _accentFor(NotificationKind kind) {
    switch (kind) {
      case NotificationKind.security:
        return AppColors.error;
      case NotificationKind.access:
        return AppColors.primary;
      case NotificationKind.bill:
        return AppColors.warning;
      case NotificationKind.community:
        return AppColors.purple;
      case NotificationKind.system:
        return AppColors.info;
    }
  }
}
