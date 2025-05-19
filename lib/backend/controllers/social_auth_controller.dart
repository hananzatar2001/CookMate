import 'dart:io';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SocialAuth {
  final GoogleSignIn _googleSignIn = GoogleSignIn();


  Future<void> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        print(' Google user: ${account.email}');
        // send to backend if needed
      } else {
        print(' Google Sign-In was cancelled.');
      }
    } catch (e) {
      print(' Google Sign-In error: $e');
    }
  }


  Future<void> signInWithFacebook() async {
    try {
      final result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final userData = await FacebookAuth.instance.getUserData();
        print(' Facebook user: ${userData['email']}');
        // send to backend if needed
      } else {
        print(' Facebook Sign-In failed: ${result.status}');
      }
    } catch (e) {
      print('⚠ Facebook Sign-In error: $e');
    }
  }


  bool get showAppleLogin => Platform.isIOS;
}
//s