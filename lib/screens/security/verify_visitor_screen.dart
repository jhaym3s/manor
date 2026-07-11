import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:manor/blocs/auth/auth_bloc.dart';
import 'package:manor/core/di/injection.dart';
import 'package:manor/core/theme/app_colors.dart';
import 'package:manor/core/theme/app_theme.dart';
import 'package:manor/data/repositories/access_code_repository.dart';

import '../../models/access_code.dart';

/// Manual gate-code check against estates/{estateId}/accessCodes.
///
/// Blocked until manor_admin's firestore.rules grants security-role read
/// access to accessCodes (currently only the owning resident can read their
/// own household's codes) — verifying will fail with permission-denied
/// until then.
class VerifyVisitorScreen extends StatefulWidget {
  const VerifyVisitorScreen({super.key});

  @override
  State<VerifyVisitorScreen> createState() => _VerifyVisitorScreenState();
}

class _VerifyVisitorScreenState extends State<VerifyVisitorScreen> {
  final _controller = TextEditingController();
  AccessCode? _result;
  bool _checked = false;
  bool _verifying = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final estateId = context.read<AuthBloc>().state.user?.estateId;
    if (estateId == null) return;

    setState(() {
      _verifying = true;
      _error = null;
    });
    try {
      final match = await getIt<AccessCodeRepository>().verifyCode(
        estateId,
        _controller.text.trim(),
      );
      setState(() {
        _result = match;
        _checked = true;
        _verifying = false;
      });
    } catch (_) {
      setState(() {
        _verifying = false;
        _error = 'Could not verify the code — try again.';
      });
    }
  }

  void _reset() {
    setState(() {
      _controller.clear();
      _result = null;
      _checked = false;
      _error = null;
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
        if (_error != null) ...[
          const SizedBox(height: 16),
          Text(
            _error!,
            style: const TextStyle(color: AppColors.statusOverdue, fontSize: 13),
          ),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed: isValid && !_verifying ? _verify : null,
            style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(fontSize: 20),
            ),
            child: _verifying
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Verify'),
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
