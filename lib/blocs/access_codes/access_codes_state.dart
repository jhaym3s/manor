part of 'access_codes_bloc.dart';

enum AccessCodesPhase { initial, loading, loaded, error }

class AccessCodesState extends Equatable {
  final AccessCodesPhase phase;
  final List<AccessCode> codes;
  final String? estateId;
  final String? householdId;
  final String? errorMessage;

  const AccessCodesState({
    this.phase = AccessCodesPhase.initial,
    this.codes = const [],
    this.estateId,
    this.householdId,
    this.errorMessage,
  });

  AccessCodesState copyWith({
    AccessCodesPhase? phase,
    List<AccessCode>? codes,
    String? estateId,
    String? householdId,
    String? errorMessage,
  }) {
    return AccessCodesState(
      phase: phase ?? this.phase,
      codes: codes ?? this.codes,
      estateId: estateId ?? this.estateId,
      householdId: householdId ?? this.householdId,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [phase, codes, estateId, householdId, errorMessage];
}
