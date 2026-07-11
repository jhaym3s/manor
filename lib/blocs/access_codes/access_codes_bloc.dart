import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/repositories/access_code_repository.dart';
import '../../models/access_code.dart';

part 'access_codes_event.dart';
part 'access_codes_state.dart';

@injectable
class AccessCodesBloc extends Bloc<AccessCodesEvent, AccessCodesState> {
  final AccessCodeRepository _repository;
  StreamSubscription<List<AccessCode>>? _subscription;

  AccessCodesBloc(this._repository) : super(const AccessCodesState()) {
    on<AccessCodesStarted>(_onStarted);
    on<AccessCodeCreateRequested>(_onCreateRequested);
    on<AccessCodeDeleteRequested>(_onDeleteRequested);
    on<_AccessCodesUpdated>(_onUpdated);
    on<_AccessCodesFailed>(_onFailed);
  }

  void _onStarted(AccessCodesStarted event, Emitter<AccessCodesState> emit) {
    emit(
      state.copyWith(
        phase: AccessCodesPhase.loading,
        estateId: event.estateId,
        householdId: event.householdId,
      ),
    );
    _subscription?.cancel();
    _subscription = _repository
        .watchAccessCodes(event.estateId, event.householdId)
        .listen(
          (codes) => add(_AccessCodesUpdated(codes)),
          onError: (Object error) => add(_AccessCodesFailed(error.toString())),
        );
  }

  Future<void> _onCreateRequested(
    AccessCodeCreateRequested event,
    Emitter<AccessCodesState> emit,
  ) async {
    final estateId = state.estateId;
    final householdId = state.householdId;
    if (estateId == null || householdId == null) return;
    await _repository.createAccessCode(estateId, householdId, event.draft);
  }

  Future<void> _onDeleteRequested(
    AccessCodeDeleteRequested event,
    Emitter<AccessCodesState> emit,
  ) async {
    final estateId = state.estateId;
    if (estateId == null) return;
    await _repository.deleteAccessCode(estateId, event.codeId);
  }

  void _onUpdated(_AccessCodesUpdated event, Emitter<AccessCodesState> emit) {
    emit(state.copyWith(phase: AccessCodesPhase.loaded, codes: event.codes));
  }

  void _onFailed(_AccessCodesFailed event, Emitter<AccessCodesState> emit) {
    emit(
      state.copyWith(
        phase: AccessCodesPhase.error,
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
