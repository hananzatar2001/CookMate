import 'package:cloud_firestore/cloud_firestore.dart';

class LoginService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {

      final querySnapshot = await firestore
          .collection('User')
          .where('email', isEqualTo: email)
          .where('password_hash', isEqualTo: password)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        print('Login successful');
        return null; // success
      } else {
        print(' Invalid email or password');
        return 'Invalid email or password';
      }
    } catch (e) {
      print(' Firestore Error during login: $e');
      return 'An error occurred during login: $e';
    }
  }
}
//s