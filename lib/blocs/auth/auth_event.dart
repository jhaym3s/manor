part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Fired once at app start to pick up an existing Firebase session.
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthPhoneNumberSubmitted extends AuthEvent {
  final String phoneNumber;
  const AuthPhoneNumberSubmitted(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class AuthOtpSubmitted extends AuthEvent {
  final String smsCode;
  const AuthOtpSubmitted(this.smsCode);

  @override
  List<Object?> get props => [smsCode];
}

/// Retries the resident-invite lookup without re-verifying the phone —
/// for the "I've been added now, try again" button.
class AuthRegistrationRecheckRequested extends AuthEvent {
  const AuthRegistrationRecheckRequested();
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthFirebaseUserChanged extends AuthEvent {
  final User? firebaseUser;
  const AuthFirebaseUserChanged(this.firebaseUser);

  @override
  List<Object?> get props => [firebaseUser];
}

class AuthCodeSent extends AuthEvent {
  final String verificationId;
  const AuthCodeSent(this.verificationId);

  @override
  List<Object?> get props => [verificationId];
}

class AuthVerificationFailed extends AuthEvent {
  final String message;
  const AuthVerificationFailed(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthAutoCredentialReceived extends AuthEvent {
  final PhoneAuthCredential credential;
  const AuthAutoCredentialReceived(this.credential);

  @override
  List<Object?> get props => [credential];
}
