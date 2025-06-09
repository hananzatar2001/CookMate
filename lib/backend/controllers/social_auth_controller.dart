import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SocialAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<void> signInWithGoogle(BuildContext context) async {
    try {

      await GoogleSignIn().signOut();

      final googleSignIn = GoogleSignIn(
        forceCodeForRefreshToken: true,
        scopes: ['email'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print(' Google Sign-In cancelled.');
        return;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        print(' Firebase user is null after Google login.');
        return;
      }

      await _handleUserData(user, context);
    } catch (e) {
      print(' Google Sign-In error: $e');
    }
  }


  Future<void> signInWithFacebook(BuildContext context) async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status != LoginStatus.success) {
        print(' Facebook login failed: ${result.status}');
        return;
      }

      final OAuthCredential facebookCredential =
      FacebookAuthProvider.credential(result.accessToken!.token);

      final UserCredential userCredential =
      await _auth.signInWithCredential(facebookCredential);
      final user = userCredential.user;

      if (user == null) {
        print(' Firebase user is null after Facebook login.');
        return;
      }

      await _handleUserData(user, context);
    } catch (e) {
      print(' Facebook Sign-In error: $e');
    }
  }

  Future<void> _handleUserData(User user, BuildContext context) async {
    final querySnapshot = await _firestore
        .collection('User')
        .where('email', isEqualTo: user.email)
        .limit(1)
        .get();

    String userId;

    if (querySnapshot.docs.isEmpty) {

      userId = DateTime.now().millisecondsSinceEpoch.toString();
      await _firestore.collection('User').doc(userId).set({
        'user_id': userId,
        'email': user.email,
        'name': user.displayName ?? '',
        'profile_picture': user.photoURL ?? '',
        'Age': 0,
        'Weight': 0.0,
        'Height': 0.0,
        'Gender': '',
        'Specific allergies': '',
        'Diseases': '',
        'Are you a vegetarian?': false,
      });
      print(' New user saved to Firestore.');
    } else {

      userId = querySnapshot.docs.first.id;
      print(' Existing user loaded from Firestore.');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);

    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }


  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut();
      await FacebookAuth.instance.logOut();
      print(' Signed out from Firebase + Google + Facebook');
    } catch (e) {
      print(' Sign out error:$e');
    }
  }


  bool get showAppleLogin => Platform.isIOS;
}
