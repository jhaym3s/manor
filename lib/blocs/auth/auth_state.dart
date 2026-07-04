part of 'auth_bloc.dart';

enum AuthPhase {
  /// Checking for an existing Firebase session at app start.
  initial,

  /// No verified phone session — show the phone-entry/welcome flow.
  unauthenticated,

  /// SMS code sent — show the OTP entry screen.
  codeSent,

  /// A phone/OTP submission or invite lookup is in flight.
  submitting,

  /// Phone verified and a matching resident profile was loaded.
  authenticated,

  /// Phone verified, but no estate admin has invited this number yet.
  notRegistered,
}

class AuthState extends Equatable {
  final AuthPhase phase;
  final String? phoneNumber;
  final String? verificationId;
  final AppUser? user;
  final String? errorMessage;

  const AuthState({
    this.phase = AuthPhase.initial,
    this.phoneNumber,
    this.verificationId,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthPhase? phase,
    String? phoneNumber,
    String? verificationId,
    AppUser? user,
    String? errorMessage,
  }) {
    return AuthState(
      phase: phase ?? this.phase,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      verificationId: verificationId ?? this.verificationId,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    phase,
    phoneNumber,
    verificationId,
    user,
    errorMessage,
  ];
}
