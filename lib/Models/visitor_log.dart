import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// A visitor entry at `estates/{estateId}/visitorLogs/{id}` (see
/// manor_admin's shared schema). Read-only from this app for now.
enum VisitorLogStatus {
  expected,
  checkedIn,
  checkedOut,
  denied;

  static VisitorLogStatus fromFirestore(String? value) {
    switch (value) {
      case 'checked-in':
        return VisitorLogStatus.checkedIn;
      case 'checked-out':
        return VisitorLogStatus.checkedOut;
      case 'denied':
        return VisitorLogStatus.denied;
      case 'expected':
      default:
        return VisitorLogStatus.expected;
    }
  }
}

class VisitorLog extends Equatable {
  final String id;
  final String? householdId;
  final String visitorName;
  final String? purpose;
  final String? accessCode;
  final VisitorLogStatus status;
  final DateTime? checkInAt;
  final DateTime? checkOutAt;
  final DateTime? createdAt;

  const VisitorLog({
    required this.id,
    this.householdId,
    required this.visitorName,
    this.purpose,
    this.accessCode,
    this.status = VisitorLogStatus.expected,
    this.checkInAt,
    this.checkOutAt,
    this.createdAt,
  });

  /// The best timestamp to show for this entry: when the visitor actually
  /// checked in if known, otherwise when the log entry was created.
  DateTime? get displayTime => checkInAt ?? createdAt;

  factory VisitorLog.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return VisitorLog(
      id: doc.id,
      householdId: data['householdId'] as String?,
      visitorName: data['visitorName'] as String? ?? 'Unknown visitor',
      purpose: data['purpose'] as String?,
      accessCode: data['accessCode'] as String?,
      status: VisitorLogStatus.fromFirestore(data['status'] as String?),
      checkInAt: (data['checkInAt'] as Timestamp?)?.toDate(),
      checkOutAt: (data['checkOutAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    householdId,
    visitorName,
    purpose,
    accessCode,
    status,
    checkInAt,
    checkOutAt,
    createdAt,
  ];
}
