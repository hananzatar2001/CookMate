import 'package:flutter/material.dart';

class EditProfileDialog extends StatelessWidget {
  final String currentBio;
  final String userId;
  final Future<void> Function(String userId, String bio) onSave;

  const EditProfileDialog({
    super.key,
    required this.currentBio,
    required this.userId,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController _bioController = TextEditingController(text: currentBio);

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Edit Bio"),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: TextField(
        controller: _bioController,
        maxLines: null,
        decoration: const InputDecoration(
          labelText: "Enter new bio",
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            final newBio = _bioController.text.trim();
            await onSave(userId, newBio);
            Navigator.pop(context);
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
