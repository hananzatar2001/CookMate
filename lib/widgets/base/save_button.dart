import 'package:flutter/material.dart';

class SaveButton extends StatelessWidget {
  final bool isEnabled;

  final Color primaryColor;

  final String buttonText;

  final VoidCallback? onPressed;

  final double height;

  final TextStyle? textStyle;

  const SaveButton({
    Key? key,
    this.isEnabled = true,
    required this.primaryColor,
    required this.onPressed,
    this.buttonText = 'Save Changes',
    this.height = 50,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, height),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade300,
      ),
      child: Text(
        buttonText,
        style:
            textStyle ??
            const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
