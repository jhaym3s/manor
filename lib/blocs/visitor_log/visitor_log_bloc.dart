import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/repositories/visitor_log_repository.dart';
import '../../models/visitor_log.dart';

part 'visitor_log_event.dart';
part 'visitor_log_state.dart';

@injectable
class VisitorLogBloc extends Bloc<VisitorLogEvent, VisitorLogState> {
  final VisitorLogRepository _repository;
  StreamSubscription<List<VisitorLog>>? _subscription;

  VisitorLogBloc(this._repository) : super(const VisitorLogState()) {
    on<VisitorLogStarted>(_onStarted);
    on<_VisitorLogUpdated>(_onUpdated);
    on<_VisitorLogFailed>(_onFailed);
  }

  void _onStarted(VisitorLogStarted event, Emitter<VisitorLogState> emit) {
    emit(state.copyWith(phase: VisitorLogPhase.loading));
    _subscription?.cancel();
    _subscription = _repository.watchVisitorLogs(event.estateId).listen(
      (entries) => add(_VisitorLogUpdated(entries)),
      onError: (Object error) => add(_VisitorLogFailed(error.toString())),
    );
  }

  void _onUpdated(_VisitorLogUpdated event, Emitter<VisitorLogState> emit) {
    emit(
      state.copyWith(phase: VisitorLogPhase.loaded, entries: event.entries),
    );
  }

  void _onFailed(_VisitorLogFailed event, Emitter<VisitorLogState> emit) {
    emit(
      state.copyWith(
        phase: VisitorLogPhase.error,
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
