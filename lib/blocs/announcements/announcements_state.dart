part of 'announcements_bloc.dart';

enum AnnouncementsPhase { initial, loading, loaded, error }

class AnnouncementsState extends Equatable {
  final AnnouncementsPhase phase;
  final List<Post> posts;
  final String? estateId;
  final String? errorMessage;

  const AnnouncementsState({
    this.phase = AnnouncementsPhase.initial,
    this.posts = const [],
    this.estateId,
    this.errorMessage,
  });

  AnnouncementsState copyWith({
    AnnouncementsPhase? phase,
    List<Post>? posts,
    String? estateId,
    String? errorMessage,
  }) {
    return AnnouncementsState(
      phase: phase ?? this.phase,
      posts: posts ?? this.posts,
      estateId: estateId ?? this.estateId,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [phase, posts, estateId, errorMessage];
}
