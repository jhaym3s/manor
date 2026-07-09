part of 'visitor_log_bloc.dart';

enum VisitorLogPhase { initial, loading, loaded, error }

class VisitorLogState extends Equatable {
  final VisitorLogPhase phase;
  final List<VisitorLog> entries;
  final String? errorMessage;

  const VisitorLogState({
    this.phase = VisitorLogPhase.initial,
    this.entries = const [],
    this.errorMessage,
  });

  VisitorLogState copyWith({
    VisitorLogPhase? phase,
    List<VisitorLog>? entries,
    String? errorMessage,
  }) {
    return VisitorLogState(
      phase: phase ?? this.phase,
      entries: entries ?? this.entries,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [phase, entries, errorMessage];
}
