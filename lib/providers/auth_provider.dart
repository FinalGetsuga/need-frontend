import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:need_mobile_app/services/auth_service.dart';

class AuthProvider extends ChangeNotifier{
  AuthProvider({required AuthService authService})
      : _auth = authService,
      _currentUser = authService.currentUser {

    _sub = _auth.authStateChanges.listen((u) {
      _currentUser = u;
      notifyListeners();
    });
  }

  final AuthService _auth;
  late final StreamSubscription<User?> _sub;

  User? _currentUser;
  User? get currentUser => _currentUser;

  bool get isSignedIn => _currentUser != null;

  Future<void> login(String email, String password) async {
    await _auth.login(email, password);
  }

  Future<void> register(String email, String password, String firstName, String lastName) async {
    await _auth.register(email, password, firstName, lastName);
  }

  Future<void> logout() async {
    await _auth.logout();
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}