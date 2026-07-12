import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../models/post.dart';

@lazySingleton
class AnnouncementRepository {
  final FirebaseFirestore _firestore;

  AnnouncementRepository(this._firestore);

  /// All announcements, newest first. `announcements` is a top-level
  /// collection (not scoped under estates/{estateId}) — any signed-in
  /// user may read every estate's broadcasts per firestore.rules, so
  /// estate-relevance filtering happens client-side (see AnnouncementsBloc).
  Stream<List<Post>> watchAnnouncements() {
    return _firestore
        .collection('announcements')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Post.fromFirestore).toList());
  }

  /// Requires the signed-in user to have role == 'admin' scoped to
  /// [estateId] per firestore.rules' isEstateAdmin check.
  Future<void> createAnnouncement({
    required String author,
    required String handle,
    required String avatar,
    required String content,
    required String? estateId,
  }) {
    return _firestore.collection('announcements').add({
      'author': author,
      'handle': handle,
      'avatar': avatar,
      'content': content,
      'isOfficial': true,
      'isPinned': false,
      'estateId': estateId,
      'createdAt': FieldValue.serverTimestamp(),
      'likes': 0,
      'comments': 0,
    });
  }
}
