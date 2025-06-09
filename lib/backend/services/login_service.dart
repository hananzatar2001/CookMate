import 'package:firebase_auth/firebase_auth.dart';

class LoginService {
  final FirebaseAuth auth = FirebaseAuth.instance;


  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {

      final UserCredential userCredential =
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print(' Login successful for ${userCredential.user?.uid}');
      return null;
    } catch (e) {
      print(' Login failed:$e');
      return 'Invalid email or password';
    }
  }
}
