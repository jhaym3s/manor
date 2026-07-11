part of 'dues_bloc.dart';

abstract class DuesEvent extends Equatable {
  const DuesEvent();

  @override
  List<Object?> get props => [];
}

/// Starts (or restarts) watching dues for the given household.
class DuesStarted extends DuesEvent {
  final String estateId;
  final String householdId;
  const DuesStarted(this.estateId, this.householdId);

  @override
  List<Object?> get props => [estateId, householdId];
}

class _DuesUpdated extends DuesEvent {
  final List<Bill> bills;
  const _DuesUpdated(this.bills);

  @override
  List<Object?> get props => [bills];
}

class _DuesFailed extends DuesEvent {
  final String message;
  const _DuesFailed(this.message);

  @override
  List<Object?> get props => [message];
}
