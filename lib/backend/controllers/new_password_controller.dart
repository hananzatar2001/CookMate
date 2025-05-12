import 'package:firebase_auth/firebase_auth.dart';

class NewPasswordService {
  static Future<bool> updatePasswordWithCode({
    required String oobCode,
    required String newPassword,
  }) async {
    try {
      await FirebaseAuth.instance.confirmPasswordReset(
        code: oobCode,
        newPassword: newPassword,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      print("Password Reset Error: ${e.message}");
      return false;
    }
  }
}
