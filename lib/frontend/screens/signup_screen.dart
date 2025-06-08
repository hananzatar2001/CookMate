import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_auth_button.dart';
import '../../backend/controllers/signup_controller.dart';
import '../screens/user_profile_screen.dart';
import 'login_screen.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _controller = UserController();

  void _handleSignup() async {
    final result = await _controller.registerUser(
      username: usernameController.text,
      email: emailController.text,
      password: passwordController.text,
      context: context,
    );

    if (result == null && context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );

    }
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
              const Text('Sign Up', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
              const SizedBox(height: 80),
              CustomTextField(controller: usernameController, labelText: 'Username'),
              const SizedBox(height: 10),
              CustomTextField(controller: emailController, labelText: 'Email', keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 10),
              CustomTextField(controller: passwordController, labelText: 'Password', obscureText: true),
              const SizedBox(height: 30),
              SizedBox(
                width: 150,
                height: 40,
                child: ElevatedButton(
                  onPressed: _handleSignup,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0x99CDE26D)),
                  child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                ),
              ),
              const SizedBox(height: 30),
              SocialAuthButtons(
                onGoogleTap: () => _controller.signInWithGoogle(context),
                onFacebookTap: () => _controller.signInWithFacebook(context),
                onAppleTap: () => _controller.signInWithApple(context),
              )

            ],
          ),
        ),
      ),
    );
  }
}
