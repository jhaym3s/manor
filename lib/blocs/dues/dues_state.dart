part of 'dues_bloc.dart';

enum DuesPhase { initial, loading, loaded, error }

class DuesState extends Equatable {
  final DuesPhase phase;
  final List<Bill> bills;
  final String? errorMessage;

  const DuesState({
    this.phase = DuesPhase.initial,
    this.bills = const [],
    this.errorMessage,
  });

  DuesState copyWith({
    DuesPhase? phase,
    List<Bill>? bills,
    String? errorMessage,
  }) {
    return DuesState(
      phase: phase ?? this.phase,
      bills: bills ?? this.bills,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [phase, bills, errorMessage];
}
