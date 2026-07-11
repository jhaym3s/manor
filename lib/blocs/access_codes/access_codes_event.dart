part of 'access_codes_bloc.dart';

abstract class AccessCodesEvent extends Equatable {
  const AccessCodesEvent();

  @override
  List<Object?> get props => [];
}

/// Starts (or restarts) watching access codes for the given household.
class AccessCodesStarted extends AccessCodesEvent {
  final String estateId;
  final String householdId;
  const AccessCodesStarted(this.estateId, this.householdId);

  @override
  List<Object?> get props => [estateId, householdId];
}

class AccessCodeCreateRequested extends AccessCodesEvent {
  final AccessCodeDraft draft;
  const AccessCodeCreateRequested(this.draft);

  @override
  List<Object?> get props => [draft];
}

class AccessCodeDeleteRequested extends AccessCodesEvent {
  final String codeId;
  const AccessCodeDeleteRequested(this.codeId);

  @override
  List<Object?> get props => [codeId];
}

class _AccessCodesUpdated extends AccessCodesEvent {
  final List<AccessCode> codes;
  const _AccessCodesUpdated(this.codes);

  @override
  List<Object?> get props => [codes];
}

class _AccessCodesFailed extends AccessCodesEvent {
  final String message;
  const _AccessCodesFailed(this.message);

  @override
  List<Object?> get props => [message];
}
