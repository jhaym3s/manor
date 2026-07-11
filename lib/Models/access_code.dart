import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// An access code at `estates/{estateId}/accessCodes/{id}`. Residents own
/// the codes for their own household (create/read/delete); this is a new
/// collection with no manor_admin dashboard counterpart yet.
class AccessCode extends Equatable {
  final String id;
  final String householdId;
  final String name;
  final String code;
  final String type; // 'permanent', 'recurring', 'one-time'
  final DateTime? expiresAt;
  final DateTime? createdAt;

  const AccessCode({
    required this.id,
    required this.householdId,
    required this.name,
    required this.code,
    required this.type,
    this.expiresAt,
    this.createdAt,
  });

  /// Human-readable expiry, matching the labels the old mock data used.
  String? get expiresLabel {
    switch (type) {
      case 'permanent':
        return null;
      case 'recurring':
        return 'Weekly';
      default:
        if (expiresAt == null) return null;
        final remaining = expiresAt!.difference(DateTime.now());
        if (remaining.isNegative) return 'Expired';
        if (remaining.inHours < 1) return '${remaining.inMinutes}m left';
        if (remaining.inHours < 24) return '${remaining.inHours}h left';
        return '${remaining.inDays}d left';
    }
  }

  factory AccessCode.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AccessCode(
      id: doc.id,
      householdId: data['householdId'] as String? ?? '',
      name: data['name'] as String? ?? 'Access code',
      code: data['code'] as String? ?? '',
      type: data['type'] as String? ?? 'one-time',
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  @override
  List<Object?> get props => [id, householdId, name, code, type, expiresAt, createdAt];
}

/// The fields a resident fills in to create a new code — id/householdId/
/// createdAt are assigned by Firestore, not the form.
class AccessCodeDraft {
  final String name;
  final String code;
  final String type;
  final DateTime? expiresAt;

  const AccessCodeDraft({
    required this.name,
    required this.code,
    required this.type,
    this.expiresAt,
  });

  Map<String, dynamic> toFirestore(String householdId) {
    return {
      'householdId': householdId,
      'name': name,
      'code': code,
      'type': type,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
