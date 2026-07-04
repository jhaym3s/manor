import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manor/core/theme/app_colors.dart';
import 'package:manor/core/theme/app_theme.dart';
import '../models/access_code.dart';
import '../widgets/create_access_code_sheet.dart';

class AccessScreen extends StatefulWidget {
  const AccessScreen({super.key});

  @override
  State<AccessScreen> createState() => _AccessScreenState();
}

class _AccessScreenState extends State<AccessScreen> {
  List<AccessCode> accessCodes = AccessCode.getSampleCodes();
  String? copiedCode;

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    setState(() => copiedCode = code);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => copiedCode = null);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Code copied to clipboard'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _deleteCode(int id) {
    setState(() {
      accessCodes.removeWhere((code) => code.id == id);
    });
  }

  void _showNewCodeModal() {
    CreateAccessCodeSheet.show(
      context,
      onCreate: (newCode) => setState(() => accessCodes.add(newCode)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Access Codes',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Manage gate access for visitors',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),

          // Add New Code Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showNewCodeModal,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Create New Code'),
            ),
          ),
          const SizedBox(height: 20),

          // Code Cards
          ...accessCodes.map((code) => _buildCodeCard(code)),
        ],
      ),
    );
  }

  Widget _buildCodeCard(AccessCode code) {
    Color typeColor;
    switch (code.type) {
      case 'permanent':
        typeColor = AppColors.primary;
        break;
      case 'recurring':
        typeColor = AppColors.info;
        break;
      default:
        typeColor = AppColors.purple;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    code.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: typeColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      code.type.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _deleteCode(code.id),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Code Display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: code.code.split('').map((digit) {
              return Container(
                width: 44,
                height: 52,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.surfaceVariant, AppColors.border],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    digit,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 14),

          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                code.expires != null ? '⏱ ${code.expires}' : '✓ Never expires',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              GestureDetector(
                onTap: () => _copyCode(code.code),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: copiedCode == code.code ? AppColors.success : AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    copiedCode == code.code ? 'Copied!' : 'Copy',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}