import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// A household at `estates/{estateId}/households/{householdId}` (see
/// manor_admin's shared schema). Read-only from this app.
class Household extends Equatable {
  final String id;
  final String estateId;
  final String name;
  final String? streetId;

  const Household({
    required this.id,
    required this.estateId,
    required this.name,
    this.streetId,
  });

  factory Household.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Household(
      id: doc.id,
      estateId: data['estateId'] as String,
      name: data['name'] as String? ?? 'Household',
      streetId: data['streetId'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, estateId, name, streetId];
}
