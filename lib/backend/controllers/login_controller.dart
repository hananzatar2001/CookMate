import 'package:firebase_auth/firebase_auth.dart';

class LoginService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Login with email & password
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An error occurred during login.';
    }
  }

  /// Sign out user
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Get current logged-in user
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }
}
