import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_auth_button.dart';
import '../../backend/controllers/login_controller.dart';
import '../../backend/controllers/social_auth_controller.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final SocialAuth _socialAuth = SocialAuth();

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _handleLogin() async {
    final loginService = LoginService();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError("Please fill in all fields");
      return;
    }

    String? result = await loginService.loginUser(
      email: email,
      password: password,
    );

    if (result != null) {
      _showError(result);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login successful")),
      );
      // TODO: Navigate to home screen
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
      _showError("Apple login is not implemented yet.");
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                  'Login',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 80),
              CustomTextField(
                controller: _emailController,
                hintText: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _passwordController,
                hintText: 'Password',
                obscureText: true,
              ),
              const SizedBox(height: 45),
              SizedBox(
                width: 150,
                height: 40,
                child: ElevatedButton(
                  onPressed: _handleLogin,
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
              const SizedBox(height: 40),
              TextButton(
                onPressed: () {
                  showForgotPasswordDialog(context);
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 20,
                    shadows: [
                      Shadow(
                        color: Colors.grey,
                        offset: Offset(1, 3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 38),

              SocialAuthButtons(
                onGoogleTap: _signInWithGoogle,
                onFacebookTap: _signInWithFacebook,
                onAppleTap: _signInWithApple,
              ),

              const SizedBox(height: 130),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignupPage()),
                      );
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
