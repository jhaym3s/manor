part of 'visitor_log_bloc.dart';

abstract class VisitorLogEvent extends Equatable {
  const VisitorLogEvent();

  @override
  List<Object?> get props => [];
}

/// Starts (or restarts) watching visitor logs for the given estate.
class VisitorLogStarted extends VisitorLogEvent {
  final String estateId;
  const VisitorLogStarted(this.estateId);

  @override
  List<Object?> get props => [estateId];
}

class _VisitorLogUpdated extends VisitorLogEvent {
  final List<VisitorLog> entries;
  const _VisitorLogUpdated(this.entries);

  @override
  List<Object?> get props => [entries];
}

class _VisitorLogFailed extends VisitorLogEvent {
  final String message;
  const _VisitorLogFailed(this.message);

  @override
  List<Object?> get props => [message];
}
