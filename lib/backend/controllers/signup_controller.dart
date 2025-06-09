import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/signup_services.dart';
import 'social_auth_controller.dart';

class UserController {
  final _userService = UserService();
  final _socialAuth = SocialAuth();

  Future<String?> registerUser({
    required String username,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    if (!_validateEmail(email)) {
      _showError(context, "Enter a valid Gmail address");
      return 'Invalid email';
    }

    if (password.length < 6) {
      _showError(context, "Password must be at least 6 characters");
      return 'Weak password';
    }

    String userId = DateTime.now().millisecondsSinceEpoch.toString();
    String passwordHash = _userService.hashPassword(password);

    final error = await _userService.addUserWithCheck(
      userId: userId,
      name: username,
      email: email,
      originalPassword: password,
    );


    if (error != null) {
      _showError(context, error);
      return error;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully")),
      );
    }

    return null;
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  bool _validateEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    await _socialAuth.signInWithGoogle(context);
  }

  Future<void> signInWithFacebook(BuildContext context) async {
    await _socialAuth.signInWithFacebook(context);
  }

  void signInWithApple(BuildContext context) {
    _showError(context, "Apple login is not implemented yet.");
  }
}
