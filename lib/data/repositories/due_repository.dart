import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../models/bill.dart';

@lazySingleton
class DueRepository {
  final FirebaseFirestore _firestore;

  DueRepository(this._firestore);

  /// Live dues for [householdId] within [estateId]. Not ordered server-side
  /// (a where+orderBy combo here would require a composite Firestore index)
  /// — callers sort client-side, which the Bills UI already does.
  Stream<List<Bill>> watchDues(String estateId, String householdId) {
    return _firestore
        .collection('estates')
        .doc(estateId)
        .collection('dues')
        .where('householdId', isEqualTo: householdId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Bill.fromFirestore).toList());
  }
}
