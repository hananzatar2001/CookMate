import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String?> resetPasswordWithToken({
    required String email,
    required String newPassword,
    required String token,
  }) async {
    try {
      print(' started resetPasswordWithToken');

      final query = await firestore
          .collection('User')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      print(' Firestore query complete');

      if (query.docs.isEmpty) {
        print(' No user found with that email');
        return 'User not found';
      }

      final userDoc = query.docs.first;
      final data = userDoc.data();

      final storedToken = data['resetToken'];
      final expiry = DateTime.tryParse(data['resetTokenExpiry'] ?? '');

      if (storedToken != token) {
        print(' Invalid token');
        return 'Invalid reset token';
      }

      if (expiry == null || DateTime.now().isAfter(expiry)) {
        print(' Token expired');
        return 'Reset token has expired';
      }

      final currentUser = auth.currentUser;
      if (currentUser == null) {
        print(' No user logged in');
        return 'You must be logged in to reset password.';
      }

      print(' Trying to update password in FirebaseAuth...');
      await currentUser.updatePassword(newPassword);
      print(' Firebase password updated');

      return null;
    } catch (e) {
      print(' Error during password reset: $e');
      return 'Password reset failed:$e';
    }
  }
}
