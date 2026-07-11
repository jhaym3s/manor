import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../models/household.dart';

/// Households change rarely, so results are cached in memory for the app's
/// lifetime instead of re-fetching every time a widget rebuilds.
@lazySingleton
class HouseholdRepository {
  final FirebaseFirestore _firestore;
  final Map<String, Household> _cache = {};

  HouseholdRepository(this._firestore);

  Future<Household?> getHousehold(String estateId, String householdId) async {
    final cached = _cache[householdId];
    if (cached != null) return cached;

    final doc = await _firestore
        .collection('estates')
        .doc(estateId)
        .collection('households')
        .doc(householdId)
        .get();
    if (!doc.exists) return null;

    final household = Household.fromFirestore(doc);
    _cache[householdId] = household;
    return household;
  }
}
