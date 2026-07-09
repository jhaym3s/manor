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
}
