import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../../backend/controllers/signup_controller.dart';
import '../widgets/social_auth_button.dart';
import '../../backend/controllers/social_auth_controller.dart';

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
    final signupService = SignupService();

    String username = usernameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (!_validateEmail(email)) {
      _showError("Enter a valid email address");
      return;
    }

    if (password.length < 6) {
      _showError("Password must be at least 6 characters");
      return;
    }

    String? result = await signupService.registerUser(
      username: username,
      email: email,
      password: password,
    );

    if (result != null) {
      _showError(result);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully")),
      );
      // يمكنك التنقل لصفحة أخرى هنا إذا أردت
    }
  }

  Future<void> _signInWithGoogle() async {
    await _socialAuth.signInWithGoogle();
  }

  Future<void> _signInWithFacebook() async {
    await _socialAuth.signInWithFacebook();
  }

  Future<void> _signInWithApple() async {
    if (_socialAuth.showAppleLogin) {
      // حالياً لسه مش مفعّل تسجيل الدخول باستخدام Apple
      _showError("Apple login is not implemented yet.");
    }
  }

  bool _validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
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
                hintText: 'Username',
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: emailController,
                hintText: 'Email address',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),
              const SizedBox(height: 50),
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
                    'Continue',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 52),
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
