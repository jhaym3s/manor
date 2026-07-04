import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:manor/core/theme/app_colors.dart';
import 'package:manor/core/theme/app_theme.dart';

import '../../models/access_code.dart';

/// Manual gate-code check. NOTE: there's no shared Firestore-backed visitor
/// system yet, so this validates against the same local sample codes used
/// elsewhere in the app — a placeholder for the real shared visitor lookup.
class VerifyVisitorScreen extends StatefulWidget {
  const VerifyVisitorScreen({super.key});

  @override
  State<VerifyVisitorScreen> createState() => _VerifyVisitorScreenState();
}

class _VerifyVisitorScreenState extends State<VerifyVisitorScreen> {
  final _controller = TextEditingController();
  AccessCode? _result;
  bool _checked = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _verify() {
    final code = _controller.text.trim();
    final match = AccessCode.getSampleCodes()
        .where((c) => c.code == code)
        .firstOrNull;
    setState(() {
      _result = match;
      _checked = true;
    });
  }

  void _reset() {
    setState(() {
      _controller.clear();
      _result = null;
      _checked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('Verify Visitor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _checked ? _buildResult() : _buildEntry(),
      ),
    );
  }

  Widget _buildEntry() {
    final isValid = _controller.text.trim().length == 6;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.qr_code_scanner,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          "Enter the visitor's gate code",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Ask the visitor for their 6-digit code',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            boxShadow: AppTheme.cardShadow,
          ),
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() {}),
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: 12,
              color: AppColors.primary,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed: isValid ? _verify : null,
            style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(fontSize: 20),
            ),
            child: const Text('Verify'),
          ),
        ),
      ],
    );
  }

  Widget _buildResult() {
    final granted = _result != null;
    final color = granted ? AppColors.statusResolved : AppColors.statusOverdue;
    final bgColor = granted
        ? AppColors.statusResolvedLight
        : AppColors.statusOverdueLight;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Icon(
            granted ? Icons.check_circle : Icons.cancel,
            color: color,
            size: 72,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          granted ? 'Access Granted' : 'Invalid Code',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        if (granted) ...[
          const SizedBox(height: 8),
          Text(
            _result!.name,
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed: _reset,
            style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(fontSize: 20),
            ),
            child: const Text('Check Another Code'),
          ),
        ),
      ],
    );
  }
}
