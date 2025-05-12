import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordService {
  static Future<bool> sendResetEmail({required String email}) async {
    try {
      final ActionCodeSettings actionCodeSettings = ActionCodeSettings(

        url: 'https://cookmate.page.link/resetpassword?continueUrl=https://cookmate-e6def.firebaseapp.com/reset-handler',
        handleCodeInApp: true,
        androidPackageName: 'at.eman.cookmate',
        androidInstallApp: true,
        androidMinimumVersion: '21',
      );

      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );

      return true; // ✅ نجح الإرسال
    } catch (e) {
      print("ForgotPassword Error: $e");
      return false;
    }
  }
}
