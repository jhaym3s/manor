import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

const _monthAbbrev = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// A due at `estates/{estateId}/dues/{dueId}` (see manor_admin's shared
/// schema), shaped for the Bills UI. Read-only from this app for now.
class Bill extends Equatable {
  final String id;
  final String name;
  final double amount;
  final String due;
  final String status; // 'pending', 'overdue', 'upcoming', 'paid'
  final String icon;

  const Bill({
    required this.id,
    required this.name,
    required this.amount,
    required this.due,
    required this.status,
    required this.icon,
  });

  @override
  List<Object?> get props => [id, name, amount, due, status, icon];

  factory Bill.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final dueDate = (data['dueDate'] as Timestamp?)?.toDate();
    final name = data['name'] as String? ?? 'Estate Due';
    return Bill(
      id: doc.id,
      name: name,
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      due: dueDate != null ? '${_monthAbbrev[dueDate.month - 1]} ${dueDate.day}' : 'No due date',
      status: data['status'] as String? ?? 'pending',
      icon: _iconFor(name),
    );
  }

  static String _iconFor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('security')) return '🛡️';
    if (lower.contains('water')) return '💧';
    if (lower.contains('waste')) return '♻️';
    if (lower.contains('service')) return '🏛️';
    return '💳';
  }
}
