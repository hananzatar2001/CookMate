import 'package:flutter/material.dart';
import '../../backend/controllers/forgot_password_controller.dart';
import '../widgets/custom_text_field.dart';

void showForgotPasswordDialog(BuildContext context) {
  final TextEditingController emailController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        actionsPadding: const EdgeInsets.only(bottom: 10, right: 10, top: 10),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Reset Password',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter your email address to receive a reset link.'),
            const SizedBox(height: 10),
            CustomTextField(
              controller: emailController,
              hintText: 'Email address',
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();

              if (email.isEmpty) {
                Navigator.of(dialogContext).pop();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(" Please enter your email"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }


              final String? error = await ForgotPasswordService.sendResetLink(email: email);

              Navigator.of(dialogContext).pop();

              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    error == null
                        ? " Reset link sent successfully!\n A password reset link has been sent to your email."
                        : " $error\n This email address was not found in the system.",

                  ),
                  backgroundColor: error == null ? Colors.green : Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0x99CDE26D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              'Send Link',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      );
    },
  );
}
//b