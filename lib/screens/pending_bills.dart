import 'package:flutter/material.dart';
import 'package:manor/core/theme/app_colors.dart';
import '../models/bill.dart';

class PendingBillsScreen extends StatefulWidget {
  final List<Bill> bills;
  final Function(int) onPayBill;

  const PendingBillsScreen({
    super.key,
    required this.bills,
    required this.onPayBill,
  });

  @override
  State<PendingBillsScreen> createState() => _PendingBillsScreenState();
}

class _PendingBillsScreenState extends State<PendingBillsScreen> {
  String _filterStatus = 'pending';
  String _sortBy = 'due';
  Set<int> _selectedBills = {};

  List<Bill> get filteredBills {
    List<Bill> filtered = List.from(widget.bills);

    

    if (_filterStatus == 'pending') {
      filtered = filtered.where((b) => b.status != 'paid').toList();
    } else if (_filterStatus != 'all') {
      filtered = filtered.where((b) => b.status == _filterStatus).toList();
    }

    switch (_sortBy) {
      case 'amount_high':
        filtered.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'amount_low':
        filtered.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      default:
        final statusPriority = {'overdue': 0, 'pending': 1, 'upcoming': 2, 'paid': 3};
        filtered.sort((a, b) => 
          (statusPriority[a.status] ?? 4).compareTo(statusPriority[b.status] ?? 4));
    }

    return filtered;
  }

  double get totalPending {
    return widget.bills
        .where((b) => b.status != 'paid')
        .fold(0, (sum, bill) => sum + bill.amount);
  }

  double get selectedTotal {
    return widget.bills
        .where((b) => _selectedBills.contains(b.id))
        .fold(0, (sum, bill) => sum + bill.amount);
  }

  int get overdueCount => widget.bills.where((b) => b.status == 'overdue').length;

  void _toggleSelection(int billId) {
    setState(() {
      if (_selectedBills.contains(billId)) {
        _selectedBills.remove(billId);
      } else {
        _selectedBills.add(billId);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selectedBills = filteredBills
          .where((b) => b.status != 'paid')
          .map((b) => b.id)
          .toSet();
    });
  }

  void _clearSelection() {
    setState(() => _selectedBills.clear());
  }

  void _showPayModal(Bill bill) {
    String selectedMethod = 'card';

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
                  'Pay Bill',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bill.name,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(bill.icon, style: const TextStyle(fontSize: 36)),
                      const SizedBox(height: 8),
                      Text(
                        '₦${bill.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Due: ${bill.due}',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildPaymentMethodOption(
                  '💳', 'Debit Card', selectedMethod == 'card',
                  () => setModalState(() => selectedMethod = 'card'),
                ),
                const SizedBox(height: 10),
                _buildPaymentMethodOption(
                  '🏦', 'Bank Transfer', selectedMethod == 'bank',
                  () => setModalState(() => selectedMethod = 'bank'),
                ),
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
                        onPressed: () {
                          widget.onPayBill(bill.id);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Payment successful!'),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                        child: const Text('Confirm'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _paySelectedBills() {
    if (_selectedBills.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
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
                'Pay Selected Bills',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_selectedBills.length} bills selected',
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₦${selectedTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
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
                      onPressed: () {
                        for (var id in _selectedBills) {
                          widget.onPayBill(id);
                        }
                        Navigator.pop(context);
                        setState(() => _selectedBills.clear());
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('All payments successful!'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                      child: const Text('Pay All'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodOption(String icon, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textTertiary,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
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
          'Pending Bills',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          // Summary Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  'Total Outstanding',
                  style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8)),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '₦${totalPending.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildStatChip(
                      '${widget.bills.where((b) => b.status != 'paid').length}',
                      'Pending',
                      Colors.white.withOpacity(0.2),
                    ),
                    if (overdueCount > 0)
                      _buildStatChip(
                        '$overdueCount',
                        'Overdue',
                        AppColors.error.withOpacity(0.8),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Filter & Sort
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Unpaid', 'pending'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Overdue', 'overdue'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Upcoming', 'upcoming'),
                      const SizedBox(width: 8),
                      _buildFilterChip('All', 'all'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      'Sort:',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                            DropdownMenuItem(value: 'due', child: Text('Due Date')),
                            DropdownMenuItem(value: 'amount_high', child: Text('Amount ↓')),
                            DropdownMenuItem(value: 'amount_low', child: Text('Amount ↑')),
                          ],
                          onChanged: (value) => setState(() => _sortBy = value ?? 'due'),
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (_selectedBills.isEmpty)
                      TextButton(
                        onPressed: _selectAll,
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: const Text('Select All', style: TextStyle(fontSize: 13)),
                      )
                    else
                      TextButton(
                        onPressed: _clearSelection,
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: const Text('Clear', style: TextStyle(fontSize: 13)),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Bills List
          Expanded(
            child: filteredBills.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, _selectedBills.isNotEmpty ? 100 : 20),
                    itemCount: filteredBills.length,
                    itemBuilder: (context, index) => _buildBillCard(filteredBills[index]),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _selectedBills.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_selectedBills.length} selected',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '₦${selectedTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _paySelectedBills,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                      child: const Text('Pay Selected'),
                    ),
                  ],
                ),
              ),
            )
          : null,
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
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.check_circle_outline, size: 40, color: AppColors.success),
            ),
            const SizedBox(height: 16),
            const Text(
              'All caught up!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'No pending bills',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String status) {
    final isSelected = _filterStatus == status;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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

  Widget _buildBillCard(Bill bill) {
    final isSelected = _selectedBills.contains(bill.id);
    final isPaid = bill.status == 'paid';

    Color statusColor;
    Color statusBgColor;
    String statusText;

    switch (bill.status) {
      case 'paid':
        statusColor = AppColors.success;
        statusBgColor = AppColors.successLight;
        statusText = 'Paid';
        break;
      case 'overdue':
        statusColor = AppColors.error;
        statusBgColor = AppColors.errorLight;
        statusText = 'Overdue';
        break;
      case 'upcoming':
        statusColor = AppColors.info;
        statusBgColor = const Color(0xFFE0F2FE);
        statusText = 'Upcoming';
        break;
      default:
        statusColor = AppColors.warning;
        statusBgColor = AppColors.warningLight;
        statusText = 'Due Soon';
    }

    return GestureDetector(
      onTap: isPaid ? null : () => _toggleSelection(bill.id),
      onLongPress: isPaid ? null : () => _showPayModal(bill),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Overdue Banner
            if (bill.status == 'overdue')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning_amber, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'OVERDUE',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Checkbox
                  if (!isPaid) ...[
                    GestureDetector(
                      onTap: () => _toggleSelection(bill.id),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: 2,
                          ),
                          color: isSelected ? AppColors.primary : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, size: 12, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],

                  // Icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: Text(bill.icon, style: const TextStyle(fontSize: 20))),
                  ),
                  const SizedBox(width: 12),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bill.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Due: ${bill.due}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Amount & Action
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₦${bill.amount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isPaid ? AppColors.textTertiary : AppColors.textPrimary,
                          decoration: isPaid ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (!isPaid)
                        GestureDetector(
                          onTap: () => _showPayModal(bill),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: bill.status == 'overdue' ? AppColors.error : AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Pay',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check, size: 12, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                'Paid',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}