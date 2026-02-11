import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manor/core/theme/app_colors.dart';
import '../models/access_code.dart';

class ActiveCodesScreen extends StatefulWidget {
  final List<AccessCode> codes;
  final Function(AccessCode) onAddCode;
  final Function(int) onDeleteCode;

  const ActiveCodesScreen({
    super.key,
    required this.codes,
    required this.onAddCode,
    required this.onDeleteCode,
  });

  @override
  State<ActiveCodesScreen> createState() => _ActiveCodesScreenState();
}

class _ActiveCodesScreenState extends State<ActiveCodesScreen> {
  String? copiedCode;
  String _filterType = 'all';
  String _sortBy = 'recent';

  List<AccessCode> get filteredCodes {
    List<AccessCode> filtered = List.from(widget.codes);

    if (_filterType != 'all') {
      filtered = filtered.where((c) => c.type == _filterType).toList();
    }

    switch (_sortBy) {
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'type':
        filtered.sort((a, b) => a.type.compareTo(b.type));
        break;
      default:
        filtered.sort((a, b) => b.id.compareTo(a.id));
    }

    return filtered;
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

  void _shareCode(AccessCode code) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing code for ${code.name}: ${code.code}'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showDeleteConfirmation(AccessCode code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Access Code'),
        content: Text('Are you sure you want to delete the code for "${code.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.onDeleteCode(code.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
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
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
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
                        decoration: const InputDecoration(hintText: 'e.g., Plumber, Friend'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
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
                                    code: (100000 + Random().nextInt(900000)).toString(),
                                    type: codeType,
                                    expires: codeType == 'permanent'
                                        ? null
                                        : codeType == 'one-time'
                                            ? '${duration}h'
                                            : 'Weekly',
                                  );
                                  widget.onAddCode(newCode);
                                  Navigator.pop(context);
                                }
                              : null,
                          child: const Text('Generate'),
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
              fontSize: 11,
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Active Codes',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                '${widget.codes.length} Active',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter & Sort Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('One-time', 'one-time'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Recurring', 'recurring'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Permanent', 'permanent'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      'Sort by:',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButton<String>(
                          value: _sortBy,
                          isDense: true,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 'recent', child: Text('Recent')),
                            DropdownMenuItem(value: 'name', child: Text('Name')),
                            DropdownMenuItem(value: 'type', child: Text('Type')),
                          ],
                          onChanged: (value) => setState(() => _sortBy = value ?? 'recent'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Codes List
          Expanded(
            child: filteredCodes.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: filteredCodes.length,
                    itemBuilder: (context, index) => _buildCodeCard(filteredCodes[index]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewCodeModal,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('New Code', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.lock_outline, size: 40, color: AppColors.textTertiary),
            ),
            const SizedBox(height: 16),
            const Text(
              'No codes found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Create a new access code to get started',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String type) {
    final isSelected = _filterType == type;
    return GestureDetector(
      onTap: () => setState(() => _filterType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildCodeCard(AccessCode code) {
    Color typeColor;
    IconData typeIcon;
    switch (code.type) {
      case 'permanent':
        typeColor = AppColors.primary;
        typeIcon = Icons.all_inclusive;
        break;
      case 'recurring':
        typeColor = AppColors.info;
        typeIcon = Icons.repeat;
        break;
      default:
        typeColor = const Color(0xFF6366F1);
        typeIcon = Icons.timer;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: typeColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(typeIcon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        code.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: typeColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              code.type.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            code.expires != null ? '⏱ ${code.expires}' : '✓ Never expires',
                            style: TextStyle(
                              fontSize: 11,
                              color: code.expires != null ? AppColors.textSecondary : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.textSecondary, size: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (value) {
                    if (value == 'delete') _showDeleteConfirmation(code);
                    if (value == 'share') _shareCode(code);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'share', child: Text('Share')),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Code Display - Responsive
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final digitWidth = (constraints.maxWidth - 40) / 6; // 6 digits with spacing
                final size = digitWidth.clamp(36.0, 48.0);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: code.code.split('').map((digit) {
                    return Container(
                      width: size,
                      height: size * 1.2,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border.withOpacity(0.5)),
                      ),
                      child: Center(
                        child: Text(
                          digit,
                          style: TextStyle(
                            fontSize: size * 0.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () => _shareCode(code),
                      child: const Text('Share', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () => _copyCode(code.code),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: copiedCode == code.code ? AppColors.success : AppColors.primary,
                      ),
                      child: Text(
                        copiedCode == code.code ? 'Copied!' : 'Copy',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
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