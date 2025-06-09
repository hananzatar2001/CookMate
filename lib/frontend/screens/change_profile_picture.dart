import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../backend/services/profile_service.dart';

class ChangeProfilePicture extends StatefulWidget {
  final String userId;
  final ProfileRecipeService profileService;

  const ChangeProfilePicture({
    super.key,
    required this.userId,
    required this.profileService,
  });

  @override
  State<ChangeProfilePicture> createState() => _ChangeProfilePictureState();
}

class _ChangeProfilePictureState extends State<ChangeProfilePicture> {
  @override
  void initState() {
    super.initState();
    _pickImage();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (!mounted) return;

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      await widget.profileService.updateUserProfilePicture(widget.userId, file);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
