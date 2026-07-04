import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import '../../models/app_user.dart';

/// Thrown when a phone number verifies successfully but no estate admin
/// has created an invite for it yet — the resident isn't provisioned.
class ResidentNotInvitedException implements Exception {}

@lazySingleton
class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository(this._firebaseAuth, this._firestore);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(PhoneAuthCredential credential) onAutoVerified,
    required void Function(FirebaseAuthException error) onFailed,
  }) {
    return _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: onAutoVerified,
      verificationFailed: onFailed,
      codeSent: (verificationId, resendToken) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<UserCredential> confirmOtp({
    required String verificationId,
    required String smsCode,
  }) {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return _firebaseAuth.signInWithCredential(credential);
  }

  Future<UserCredential> confirmCredential(PhoneAuthCredential credential) {
    return _firebaseAuth.signInWithCredential(credential);
  }

  /// Loads the resident's profile, creating it from a matching estate-admin
  /// invite the first time this (now verified) phone number signs in.
  /// Throws [ResidentNotInvitedException] if no admin has invited this phone.
  Future<AppUser> loadOrCreateProfile(User firebaseUser) async {
    final phone = firebaseUser.phoneNumber!;
    final userDoc = await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();
    if (userDoc.exists) {
      return AppUser.fromFirestore(userDoc);
    }

    final inviteDoc = await _firestore
        .collection('residentInvites')
        .doc(phone)
        .get();
    if (!inviteDoc.exists) {
      throw ResidentNotInvitedException();
    }

    final invite = inviteDoc.data()!;
    final appUser = AppUser(
      uid: firebaseUser.uid,
      phone: phone,
      fullName: invite['fullName'] as String,
      role: invite['role'] as String? ?? 'resident',
      estateId: invite['estateId'] as String?,
      householdId: invite['householdId'] as String?,
    );

    await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .set(appUser.toFirestore());
    await inviteDoc.reference.update({
      'claimed': true,
      'claimedAt': FieldValue.serverTimestamp(),
      'claimedByUid': firebaseUser.uid,
    });

    return appUser;
  }

  Future<void> signOut() => _firebaseAuth.signOut();
}
