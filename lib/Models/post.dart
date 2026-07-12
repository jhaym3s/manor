import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../core/utils/relative_time.dart';

/// An announcement at `announcements/{id}` (see manor_admin's shared
/// schema). Admin-authored only — residents can read but not post, like,
/// or comment (the schema only tracks aggregate counts, not per-user
/// state, and writes are admin-gated in firestore.rules).
class Post extends Equatable {
  final String id;
  final String author;
  final String handle;
  final String avatar;
  final bool isOfficial;
  final bool isPinned;
  final String content;
  final DateTime? createdAt;
  final int likes;
  final int comments;
  final String? estateId;

  const Post({
    required this.id,
    required this.author,
    required this.handle,
    required this.avatar,
    this.isOfficial = false,
    this.isPinned = false,
    required this.content,
    this.createdAt,
    required this.likes,
    required this.comments,
    this.estateId,
  });

  String get time => createdAt != null ? formatRelativeTime(createdAt!) : 'Just now';

  factory Post.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Post(
      id: doc.id,
      author: data['author'] as String? ?? 'Estate Management',
      handle: data['handle'] as String? ?? '@management',
      avatar: data['avatar'] as String? ?? '🏢',
      isOfficial: data['isOfficial'] as bool? ?? false,
      isPinned: data['isPinned'] as bool? ?? false,
      content: data['content'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      likes: (data['likes'] as num?)?.toInt() ?? 0,
      comments: (data['comments'] as num?)?.toInt() ?? 0,
      estateId: data['estateId'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    author,
    handle,
    avatar,
    isOfficial,
    isPinned,
    content,
    createdAt,
    likes,
    comments,
    estateId,
  ];
}
