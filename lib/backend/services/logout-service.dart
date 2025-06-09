/*
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../frontend/screens/login_screen.dart';

class logoutService {
  static Future<void> logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm logout'),
        content: const Text('Are you sure you want to log out ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('logout'),
          ),
        ],
      ),
    );

    if (confirm != true) return;


    await FirebaseAuth.instance.signOut();


    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');


    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../frontend/screens/login_screen.dart';

class LogoutService {
  static Future<void> logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [

          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign out'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('cancel'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await FirebaseAuth.instance.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');  // تأكد المفتاح نفس المستخدم في جميع التطبيق

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }
}
