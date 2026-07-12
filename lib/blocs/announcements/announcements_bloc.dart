import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/repositories/announcement_repository.dart';
import '../../models/post.dart';

part 'announcements_event.dart';
part 'announcements_state.dart';

@injectable
class AnnouncementsBloc extends Bloc<AnnouncementsEvent, AnnouncementsState> {
  final AnnouncementRepository _repository;
  StreamSubscription<List<Post>>? _subscription;

  AnnouncementsBloc(this._repository) : super(const AnnouncementsState()) {
    on<AnnouncementsStarted>(_onStarted);
    on<AnnouncementCreateRequested>(_onCreateRequested);
    on<_AnnouncementsUpdated>(_onUpdated);
    on<_AnnouncementsFailed>(_onFailed);
  }

  void _onStarted(AnnouncementsStarted event, Emitter<AnnouncementsState> emit) {
    emit(
      state.copyWith(
        phase: AnnouncementsPhase.loading,
        estateId: event.estateId,
      ),
    );
    _subscription?.cancel();
    _subscription = _repository.watchAnnouncements().listen(
      (posts) => add(_AnnouncementsUpdated(posts)),
      onError: (Object error) => add(_AnnouncementsFailed(error.toString())),
    );
  }

  Future<void> _onCreateRequested(
    AnnouncementCreateRequested event,
    Emitter<AnnouncementsState> emit,
  ) async {
    await _repository.createAnnouncement(
      author: 'Estate Management',
      handle: '@management',
      avatar: '🏢',
      content: event.content,
      estateId: state.estateId,
    );
  }

  void _onUpdated(_AnnouncementsUpdated event, Emitter<AnnouncementsState> emit) {
    // Estate-relevant posts only: broadcasts with no estateId are meant
    // for every estate, the rest must match the caller's own.
    final relevant = event.posts
        .where((p) => p.estateId == null || p.estateId == state.estateId)
        .toList();
    emit(state.copyWith(phase: AnnouncementsPhase.loaded, posts: relevant));
  }

  void _onFailed(_AnnouncementsFailed event, Emitter<AnnouncementsState> emit) {
    emit(
      state.copyWith(
        phase: AnnouncementsPhase.error,
        errorMessage: event.message,
      ),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
