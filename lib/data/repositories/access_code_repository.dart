import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../models/access_code.dart';

@lazySingleton
class AccessCodeRepository {
  final FirebaseFirestore _firestore;

  AccessCodeRepository(this._firestore);

  /// Live access codes for [householdId] within [estateId]. Not ordered
  /// server-side (a where+orderBy combo would require a composite index) —
  /// callers sort client-side.
  Stream<List<AccessCode>> watchAccessCodes(String estateId, String householdId) {
    return _firestore
        .collection('estates')
        .doc(estateId)
        .collection('accessCodes')
        .where('householdId', isEqualTo: householdId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(AccessCode.fromFirestore).toList());
  }

  Future<void> createAccessCode(
    String estateId,
    String householdId,
    AccessCodeDraft draft,
  ) {
    return _firestore
        .collection('estates')
        .doc(estateId)
        .collection('accessCodes')
        .add(draft.toFirestore(householdId));
  }

  Future<void> deleteAccessCode(String estateId, String codeId) {
    return _firestore
        .collection('estates')
        .doc(estateId)
        .collection('accessCodes')
        .doc(codeId)
        .delete();
  }

  /// One-shot lookup for gate verification — used by security staff to
  /// check a visitor-supplied code against any household in the estate.
  Future<AccessCode?> verifyCode(String estateId, String code) async {
    final snapshot = await _firestore
        .collection('estates')
        .doc(estateId)
        .collection('accessCodes')
        .where('code', isEqualTo: code)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return AccessCode.fromFirestore(snapshot.docs.first);
  }
}
