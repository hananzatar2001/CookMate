import 'package:flutter/material.dart';

class IncompleteProfileDialog extends StatelessWidget {
  const IncompleteProfileDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Incomplete Profile"),
      content: const Text("Please fill in your age, weight, height, and gender before accessing Calorie Tracking."),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        ),
      ],
    );
  }
}
