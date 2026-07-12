part of 'announcements_bloc.dart';

abstract class AnnouncementsEvent extends Equatable {
  const AnnouncementsEvent();

  @override
  List<Object?> get props => [];
}

/// Starts (or restarts) watching announcements, filtered client-side to
/// [estateId] (plus estate-less broadcasts).
class AnnouncementsStarted extends AnnouncementsEvent {
  final String? estateId;
  const AnnouncementsStarted(this.estateId);

  @override
  List<Object?> get props => [estateId];
}

class AnnouncementCreateRequested extends AnnouncementsEvent {
  final String content;
  const AnnouncementCreateRequested(this.content);

  @override
  List<Object?> get props => [content];
}

class _AnnouncementsUpdated extends AnnouncementsEvent {
  final List<Post> posts;
  const _AnnouncementsUpdated(this.posts);

  @override
  List<Object?> get props => [posts];
}

class _AnnouncementsFailed extends AnnouncementsEvent {
  final String message;
  const _AnnouncementsFailed(this.message);

  @override
  List<Object?> get props => [message];
}
