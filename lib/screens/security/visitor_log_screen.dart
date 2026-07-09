import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:manor/blocs/auth/auth_bloc.dart';
import 'package:manor/blocs/visitor_log/visitor_log_bloc.dart';
import 'package:manor/core/di/injection.dart';
import 'package:manor/core/theme/app_colors.dart';
import 'package:manor/core/theme/app_theme.dart';
import 'package:manor/core/utils/relative_time.dart';
import 'package:manor/models/visitor_log.dart';

class VisitorLogScreen extends StatelessWidget {
  const VisitorLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final estateId = context.read<AuthBloc>().state.user?.estateId;
    return BlocProvider<VisitorLogBloc>(
      create: (_) {
        final bloc = getIt<VisitorLogBloc>();
        if (estateId != null) {
          bloc.add(VisitorLogStarted(estateId));
        }
        return bloc;
      },
      child: const _VisitorLogView(),
    );
  }
}

class _VisitorLogView extends StatelessWidget {
  const _VisitorLogView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('Visitor Log'),
      ),
      body: BlocBuilder<VisitorLogBloc, VisitorLogState>(
        builder: (context, state) {
          switch (state.phase) {
            case VisitorLogPhase.initial:
            case VisitorLogPhase.loading:
              return const Center(child: CircularProgressIndicator());
            case VisitorLogPhase.error:
              return Center(
                child: Text(
                  state.errorMessage ?? 'Could not load the visitor log.',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              );
            case VisitorLogPhase.loaded:
              if (state.entries.isEmpty) {
                return const Center(
                  child: Text(
                    'No visitors logged yet.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: state.entries.length,
                itemBuilder: (context, index) =>
                    _buildEntry(state.entries[index]),
              );
          }
        },
      ),
    );
  }

  Widget _buildEntry(VisitorLog entry) {
    final style = _statusStyle(entry.status);
    final time = entry.displayTime;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: style.background,
              shape: BoxShape.circle,
            ),
            child: Icon(style.icon, color: style.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.visitorName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  time != null ? formatRelativeTime(time) : style.label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _StatusStyle _statusStyle(VisitorLogStatus status) {
    switch (status) {
      case VisitorLogStatus.checkedIn:
        return const _StatusStyle(
          color: AppColors.statusResolved,
          background: AppColors.statusResolvedLight,
          icon: Icons.check,
          label: 'Checked in',
        );
      case VisitorLogStatus.expected:
        return const _StatusStyle(
          color: AppColors.statusPending,
          background: AppColors.statusPendingLight,
          icon: Icons.schedule,
          label: 'Expected',
        );
      case VisitorLogStatus.denied:
        return const _StatusStyle(
          color: AppColors.statusOverdue,
          background: AppColors.statusOverdueLight,
          icon: Icons.close,
          label: 'Denied',
        );
      case VisitorLogStatus.checkedOut:
        return const _StatusStyle(
          color: AppColors.textSecondary,
          background: AppColors.surfaceVariant,
          icon: Icons.logout,
          label: 'Checked out',
        );
    }
  }
}

class _StatusStyle {
  final Color color;
  final Color background;
  final IconData icon;
  final String label;

  const _StatusStyle({
    required this.color,
    required this.background,
    required this.icon,
    required this.label,
  });
}
