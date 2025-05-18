import 'package:flutter/material.dart';
import '../../backend/controllers/social_auth_controller.dart';
import 'dart:io';

class SocialAuthButtons extends StatelessWidget {
  final VoidCallback? onGoogleTap;
  final VoidCallback? onFacebookTap;
  final VoidCallback? onAppleTap;

  const SocialAuthButtons({
    super.key,
    this.onGoogleTap,
    this.onFacebookTap,
    this.onAppleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(child: Divider(thickness: 1, color: Colors.black)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'OR',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(child: Divider(thickness: 1, color: Colors.black)),
          ],
        ),
        const SizedBox(height: 52),
        const Text(
          'Or Login Using',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onGoogleTap,
              child: Image.asset('assets/google_logo.jpeg', height: 30),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: onFacebookTap,
              child: Image.asset('assets/facebook_logo.jpeg', height: 30),
            ),
            const SizedBox(width: 20),
            if (Platform.isIOS && onAppleTap != null)
              GestureDetector(
                onTap: onAppleTap,
                child: Image.asset('assets/apple_logo.jpeg', height: 30),
              ),
          ],
        ),
      ],
    );
  }
}
//h