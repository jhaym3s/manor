import 'dart:math';
import 'package:flutter/material.dart';
import 'package:manor/core/theme/app_colors.dart';
import '../models/access_code.dart';
import 'custom_bottom_sheet.dart';

class CreateAccessCodeSheet {
  static Future<void> show(
    BuildContext context, {
    required void Function(AccessCodeDraft) onCreate,
  }) {
    return CustomBottomSheet.show(
      context: context,
      title: 'Create Access Code',
      subtitle: 'Generate a gate code for your visitor',
      child: _CreateAccessCodeForm(onCreate: onCreate),
    );
  }
}

class _CreateAccessCodeForm extends StatefulWidget {
  final void Function(AccessCodeDraft) onCreate;

  const _CreateAccessCodeForm({required this.onCreate});

  @override
  State<_CreateAccessCodeForm> createState() => _CreateAccessCodeFormState();
}

class _CreateAccessCodeFormState extends State<_CreateAccessCodeForm> {
  String codeName = '';
  String codeType = 'one-time';
  String duration = '24';

  String _generateCode() => (100000 + Random().nextInt(900000)).toString();

  void _submit() {
    final draft = AccessCodeDraft(
      name: codeName,
      code: _generateCode(),
      type: codeType,
      expiresAt: codeType == 'one-time'
          ? DateTime.now().add(Duration(hours: int.parse(duration)))
          : null,
    );
    widget.onCreate(draft);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
          onChanged: (value) => setState(() => codeName = value),
          decoration: const InputDecoration(hintText: 'e.g., Plumber, Friend'),
        ),
        const SizedBox(height: 18),
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
            _buildTypeButton('⏱ Once', 'one-time'),
            const SizedBox(width: 8),
            _buildTypeButton('🔄 Weekly', 'recurring'),
            const SizedBox(width: 8),
            _buildTypeButton('∞ Always', 'permanent'),
          ],
        ),
        if (codeType == 'one-time') ...[
          const SizedBox(height: 18),
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
            initialValue: duration,
            items: const [
              DropdownMenuItem(value: '1', child: Text('1 hour')),
              DropdownMenuItem(value: '6', child: Text('6 hours')),
              DropdownMenuItem(value: '24', child: Text('24 hours')),
              DropdownMenuItem(value: '72', child: Text('3 days')),
            ],
            onChanged: (value) => setState(() => duration = value ?? '24'),
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
                onPressed: codeName.isNotEmpty ? _submit : null,
                child: const Text('Generate Code'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeButton(String label, String type) {
    final isSelected = codeType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => codeType = type),
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
}
