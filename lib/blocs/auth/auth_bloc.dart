import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../core/config/dev_flags.dart';
import '../../data/repositories/auth_repository.dart';
import '../../models/app_user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

const _devBypassUser = AppUser(
  uid: 'dev-bypass-uid',
  phone: '+2340000000000',
  fullName: 'Dev Resident',
  role: 'resident',
  estateId: 'dev-estate',
  householdId: 'dev-household',
);

@lazySingleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authSubscription;

  AuthBloc(this._authRepository) : super(const AuthState()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthFirebaseUserChanged>(_onFirebaseUserChanged);
    on<AuthPhoneNumberSubmitted>(_onPhoneNumberSubmitted);
    on<AuthCodeSent>(_onCodeSent);
    on<AuthOtpSubmitted>(_onOtpSubmitted);
    on<AuthAutoCredentialReceived>(_onAutoCredentialReceived);
    on<AuthVerificationFailed>(_onVerificationFailed);
    on<AuthRegistrationRecheckRequested>(_onRegistrationRecheckRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);

    if (!kBypassAuth) {
      _authSubscription = _authRepository.authStateChanges.listen(
        (firebaseUser) => add(AuthFirebaseUserChanged(firebaseUser)),
      );
    }
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (kBypassAuth) {
      emit(state.copyWith(phase: AuthPhase.authenticated, user: _devBypassUser));
      return;
    }
    final firebaseUser = _authRepository.currentFirebaseUser;
    await _resolveProfile(firebaseUser, emit);
  }

  Future<void> _onFirebaseUserChanged(
    AuthFirebaseUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    await _resolveProfile(event.firebaseUser, emit);
  }

  Future<void> _resolveProfile(
    User? firebaseUser,
    Emitter<AuthState> emit,
  ) async {
    if (firebaseUser == null) {
      emit(const AuthState(phase: AuthPhase.unauthenticated));
      return;
    }

    emit(state.copyWith(phase: AuthPhase.submitting));
    try {
      final appUser = await _authRepository.loadOrCreateProfile(firebaseUser);
      emit(state.copyWith(phase: AuthPhase.authenticated, user: appUser));
    } on ResidentNotInvitedException {
      emit(state.copyWith(phase: AuthPhase.notRegistered));
    } catch (e) {
      emit(
        state.copyWith(
          phase: AuthPhase.notRegistered,
          errorMessage: 'Could not verify your invite. Pull to try again.',
        ),
      );
    }
  }

  Future<void> _onPhoneNumberSubmitted(
    AuthPhoneNumberSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        phase: AuthPhase.submitting,
        phoneNumber: event.phoneNumber,
      ),
    );
    await _authRepository.verifyPhoneNumber(
      phoneNumber: event.phoneNumber,
      onCodeSent: (verificationId) => add(AuthCodeSent(verificationId)),
      onAutoVerified: (credential) =>
          add(AuthAutoCredentialReceived(credential)),
      onFailed: (error) =>
          add(AuthVerificationFailed(_mapFirebaseError(error))),
    );
  }

  void _onCodeSent(AuthCodeSent event, Emitter<AuthState> emit) {
    emit(
      state.copyWith(
        phase: AuthPhase.codeSent,
        verificationId: event.verificationId,
      ),
    );
  }

  Future<void> _onOtpSubmitted(
    AuthOtpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (state.verificationId == null) return;
    emit(state.copyWith(phase: AuthPhase.submitting));
    try {
      await _authRepository.confirmOtp(
        verificationId: state.verificationId!,
        smsCode: event.smsCode,
      );
      // Resulting AuthAuthenticated/NotRegistered state arrives via the
      // authStateChanges subscription -> _onFirebaseUserChanged.
    } on FirebaseAuthException catch (e) {
      emit(
        state.copyWith(
          phase: AuthPhase.codeSent,
          errorMessage: _mapFirebaseError(e),
        ),
      );
    }
  }

  Future<void> _onAutoCredentialReceived(
    AuthAutoCredentialReceived event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.confirmCredential(event.credential);
    } on FirebaseAuthException catch (e) {
      emit(
        state.copyWith(
          phase: AuthPhase.codeSent,
          errorMessage: _mapFirebaseError(e),
        ),
      );
    }
  }

  void _onVerificationFailed(
    AuthVerificationFailed event,
    Emitter<AuthState> emit,
  ) {
    emit(
      state.copyWith(
        phase: AuthPhase.unauthenticated,
        errorMessage: event.message,
      ),
    );
  }

  Future<void> _onRegistrationRecheckRequested(
    AuthRegistrationRecheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _resolveProfile(_authRepository.currentFirebaseUser, emit);
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Enter a valid phone number.';
      case 'invalid-verification-code':
        return 'That code is incorrect. Please try again.';
      case 'session-expired':
      case 'code-expired':
        return 'This code has expired — request a new one.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
