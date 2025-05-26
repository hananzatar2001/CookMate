import 'package:flutter/material.dart';
import 'text_input_field.dart';

class HighlightedTextField extends StatelessWidget {
  final String label;

  final TextEditingController controller;

  final bool highlight;

  final bool isPassword;

  final VoidCallback? onEditPressed;

  final Color highlightColor;

  final Color indicatorColor;

  const HighlightedTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.highlight = false,
    this.isPassword = false,
    this.onEditPressed,
    this.highlightColor = Colors.white,
    this.indicatorColor = Colors.red,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          highlight
              ? BoxDecoration(
                border: Border.all(color: highlightColor.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: highlightColor.withOpacity(0.2),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              )
              : null,
      child: Stack(
        children: [
          TextInputField(
            label: label,
            controller: controller,
            isPassword: isPassword,
            onEditPressed: onEditPressed,
          ),
          if (highlight)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: indicatorColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
