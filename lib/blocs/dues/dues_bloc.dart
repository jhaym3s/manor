import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/repositories/due_repository.dart';
import '../../models/bill.dart';

part 'dues_event.dart';
part 'dues_state.dart';

@injectable
class DuesBloc extends Bloc<DuesEvent, DuesState> {
  final DueRepository _repository;
  StreamSubscription<List<Bill>>? _subscription;

  DuesBloc(this._repository) : super(const DuesState()) {
    on<DuesStarted>(_onStarted);
    on<_DuesUpdated>(_onUpdated);
    on<_DuesFailed>(_onFailed);
  }

  void _onStarted(DuesStarted event, Emitter<DuesState> emit) {
    emit(state.copyWith(phase: DuesPhase.loading));
    _subscription?.cancel();
    _subscription = _repository
        .watchDues(event.estateId, event.householdId)
        .listen(
          (bills) => add(_DuesUpdated(bills)),
          onError: (Object error) => add(_DuesFailed(error.toString())),
        );
  }

  void _onUpdated(_DuesUpdated event, Emitter<DuesState> emit) {
    emit(state.copyWith(phase: DuesPhase.loaded, bills: event.bills));
  }

  void _onFailed(_DuesFailed event, Emitter<DuesState> emit) {
    emit(state.copyWith(phase: DuesPhase.error, errorMessage: event.message));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
