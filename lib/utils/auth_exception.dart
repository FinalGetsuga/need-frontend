import 'package:firebase_auth/firebase_auth.dart';

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  factory AuthException.fromFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return AuthException('That email address looks invalid.');
      case 'user-disabled':
        return AuthException('This account has been disabled.');
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return AuthException('Incorrect email or password.');
      case 'email-already-in-use':
        return AuthException('An account already exists with that email.');
      case 'weak-password':
        return AuthException('Password is too weak - use at least 6 characters.');
      case 'network-request-failed':
        return AuthException('Network error. Check your connection and try again.');
      case 'too-many-requests':
        return AuthException('Too many attempts. Please wait a moment and try again.');
      default:
        return AuthException('Something went wrong. Please try again.');
    }
  }

  @override
  String toString() => message;
}