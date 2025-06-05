
import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_auth_button.dart';
import '../../backend/controllers/social_auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/user_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _socialAuth = SocialAuth();

  void _registerUser() async {
    String username = usernameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (!_validateEmail(email)) {
      _showError("Enter a valid Gmail address");
      return;
    }

    if (password.length < 6) {
      _showError("Password must be at least 6 characters");
      return;
    }

    String userId = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      // ✅ تسجيل في Firebase Auth
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // ✅ تخزين بيانات المستخدم في Firestore
      await FirebaseFirestore.instance.collection('User').doc(userId).set({
        'user_id': userId,
        'email': email,
        'name': username,
        'password_hash': password, // ممكن تشفّرها إذا حبيت
        'profile_picture': '',
        'Age': 0,
        'Weight': 0.0,
        'Height': 0.0,
        'Gender': '',
        'Specific allergies': '',
        'Diseases': '',
        'Are you a vegetarian?': false,
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    } catch (e) {
      _showError("Registration failed: ${e.toString()}");
    }
  }

  Future<void> _signInWithGoogle() async {
    await _socialAuth.signInWithGoogle(context);
  }

  Future<void> _signInWithFacebook() async {
    await _socialAuth.signInWithFacebook(context);
  }

  Future<void> _signInWithApple() async {
    if (_socialAuth.showAppleLogin) {
      _showError("Apple login is not implemented yet.");
    }
  }

  bool _validateEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 7),
                child: Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 80),
              CustomTextField(
                controller: usernameController,
                labelText: 'Username',
              //  hintText: 'Enter your username',
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: emailController,
                labelText: 'Email',
              //  hintText: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: passwordController,
                labelText: 'Password',
                //hintText: 'Enter your password',
                obscureText: true,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 150,
                height: 40,
                child: ElevatedButton(
                  onPressed: _registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0x99CDE26D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    elevation: 3,
                    shadowColor: Colors.black,
                  ),
                  child: const Text(
                    'Continue ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SocialAuthButtons(
                onGoogleTap: _signInWithGoogle,
                onFacebookTap: _signInWithFacebook,
                onAppleTap: _signInWithApple,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
