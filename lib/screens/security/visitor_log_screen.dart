import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manor/core/theme/app_colors.dart';
import 'package:manor/core/theme/app_theme.dart';

/// Placeholder log entries — there's no shared Firestore-backed visitor
/// system yet (see [VerifyVisitorScreen]), so this isn't wired to real data.
class _LogEntry {
  final String name;
  final String time;
  final bool granted;
  const _LogEntry(this.name, this.time, this.granted);
}

const _sampleLog = [
  _LogEntry('Plumber - Tunde', '10 mins ago', true),
  _LogEntry('Unknown code 384021', '32 mins ago', false),
  _LogEntry('Cleaner - Maria', '1h ago', true),
  _LogEntry('Package Delivery', '2h ago', true),
];

class VisitorLogScreen extends StatelessWidget {
  const VisitorLogScreen({super.key});

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
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _sampleLog.length,
        itemBuilder: (context, index) => _buildEntry(_sampleLog[index]),
      ),
    );
  }

  Widget _buildEntry(_LogEntry entry) {
    final color = entry.granted
        ? AppColors.statusResolved
        : AppColors.statusOverdue;
    final bgColor = entry.granted
        ? AppColors.statusResolvedLight
        : AppColors.statusOverdueLight;

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
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(
              entry.granted ? Icons.check : Icons.close,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  entry.time,
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
}
