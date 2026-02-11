import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manor/core/theme/app_colors.dart';
import '../models/access_code.dart';

class AccessScreen extends StatefulWidget {
  const AccessScreen({super.key});

  @override
  State<AccessScreen> createState() => _AccessScreenState();
}

class _AccessScreenState extends State<AccessScreen> {
  List<AccessCode> accessCodes = AccessCode.getSampleCodes();
  String? copiedCode;

  String _generateCode() {
    return (100000 + Random().nextInt(900000)).toString();
  }

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
    String codeName = '';
    String codeType = 'one-time';
    String duration = '24';

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
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
              child: Column(
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
                  const SizedBox(height: 20),
                  const Text(
                    'Create Access Code',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Generate a gate code for your visitor',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Name Input
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Name / Purpose',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        onChanged: (value) => setModalState(() => codeName = value),
                        decoration: const InputDecoration(
                          hintText: 'e.g., Plumber, Friend',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Code Type
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Code Type',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildTypeButton('⏱ Once', 'one-time', codeType, (type) {
                            setModalState(() => codeType = type);
                          }),
                          const SizedBox(width: 8),
                          _buildTypeButton('🔄 Weekly', 'recurring', codeType, (type) {
                            setModalState(() => codeType = type);
                          }),
                          const SizedBox(width: 8),
                          _buildTypeButton('∞ Always', 'permanent', codeType, (type) {
                            setModalState(() => codeType = type);
                          }),
                        ],
                      ),
                    ],
                  ),

                  if (codeType == 'one-time') ...[
                    const SizedBox(height: 18),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Valid For',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: duration,
                          decoration: const InputDecoration(),
                          items: const [
                            DropdownMenuItem(value: '1', child: Text('1 hour')),
                            DropdownMenuItem(value: '6', child: Text('6 hours')),
                            DropdownMenuItem(value: '24', child: Text('24 hours')),
                            DropdownMenuItem(value: '72', child: Text('3 days')),
                          ],
                          onChanged: (value) => setModalState(() => duration = value ?? '24'),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: codeName.isNotEmpty
                              ? () {
                                  final newCode = AccessCode(
                                    id: DateTime.now().millisecondsSinceEpoch,
                                    name: codeName,
                                    code: _generateCode(),
                                    type: codeType,
                                    expires: codeType == 'permanent'
                                        ? null
                                        : codeType == 'one-time'
                                            ? '${duration}h'
                                            : 'Weekly',
                                  );
                                  setState(() => accessCodes.add(newCode));
                                  Navigator.pop(context);
                                }
                              : null,
                          child: const Text('Generate Code'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(String label, String type, String selectedType, Function(String) onTap) {
    final isSelected = selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.successLight : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 2,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
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
            'Access Codes',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Manage gate access for visitors',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
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
        typeColor = const Color(0xFF6366F1);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
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