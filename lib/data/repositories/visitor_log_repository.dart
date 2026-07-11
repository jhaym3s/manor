import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../models/visitor_log.dart';

@lazySingleton
class VisitorLogRepository {
  final FirebaseFirestore _firestore;

  VisitorLogRepository(this._firestore);

  /// Live visitor log entries for [estateId], newest first. Requires the
  /// signed-in user to have security/admin read access under
  /// estates/{estateId}/visitorLogs per firestore.rules.
  Stream<List<VisitorLog>> watchVisitorLogs(String estateId) {
    return _firestore
        .collection('estates')
        .doc(estateId)
        .collection('visitorLogs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(VisitorLog.fromFirestore).toList());
  }

  /// Live visitor log entries for a single [householdId] — used for a
  /// resident's own activity feed, as opposed to [watchVisitorLogs]'
  /// estate-wide view for security staff. Not ordered server-side (a
  /// where+orderBy combo would require a composite index) — callers sort
  /// client-side.
  Stream<List<VisitorLog>> watchVisitorLogsForHousehold(
    String estateId,
    String householdId,
  ) {
    return _firestore
        .collection('estates')
        .doc(estateId)
        .collection('visitorLogs')
        .where('householdId', isEqualTo: householdId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(VisitorLog.fromFirestore).toList());
  }
}
