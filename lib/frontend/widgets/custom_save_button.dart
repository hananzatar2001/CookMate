import 'package:flutter/material.dart';

class CustomSaveButton extends StatelessWidget {
  final bool isSaved;
  final VoidCallback onPressed;

  const CustomSaveButton({
    Key? key,
    required this.isSaved,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Icon(
          isSaved ? Icons.bookmark : Icons.bookmark_border,
          key: ValueKey<bool>(isSaved),
          color: Colors.black,
          size: 30,
        ),
      ),
    );
  }
}
