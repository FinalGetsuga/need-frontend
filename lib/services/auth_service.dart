import 'package:firebase_auth/firebase_auth.dart';
import 'package:need_mobile_app/services/user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> register(String email, String password, String firstName, String lastName) async {
    final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password
    );

    await credential.user?.updateDisplayName('$firstName $lastName');
    await _userService.updateCurrentUser(firstName: firstName, lastName: lastName);
  }

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
        email: email,
        password: password
    );
  }

  Future<void> logout() async {
    return _auth.signOut();
  }

  Future<String?> getIdToken() async {
    return _auth.currentUser?.getIdToken();
  }
}