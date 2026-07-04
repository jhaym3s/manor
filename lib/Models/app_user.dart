import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// A resident's profile, stored at `users/{uid}` once an estate admin's
/// invite (`residentInvites/{phone}`) has been matched to a verified phone.
class AppUser extends Equatable {
  final String uid;
  final String phone;
  final String fullName;
  final String role; // 'resident' | 'security' | 'admin'
  final String? estateId;
  final String? householdId;

  const AppUser({
    required this.uid,
    required this.phone,
    required this.fullName,
    this.role = 'resident',
    this.estateId,
    this.householdId,
  });

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AppUser(
      uid: doc.id,
      phone: data['phone'] as String,
      fullName: data['fullName'] as String,
      role: data['role'] as String? ?? 'resident',
      estateId: data['estateId'] as String?,
      householdId: data['householdId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'phone': phone,
      'fullName': fullName,
      'role': role,
      'estateId': estateId,
      'householdId': householdId,
    };
  }

  @override
  List<Object?> get props => [
    uid,
    phone,
    fullName,
    role,
    estateId,
    householdId,
  ];
}
