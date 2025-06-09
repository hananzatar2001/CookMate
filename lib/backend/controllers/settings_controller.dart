import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookmate/backend/models/user_model.dart';
import 'package:cookmate/backend/services/user_service.dart';
import 'package:cookmate/backend/controllers/notifications_controller.dart';

class SettingsController extends ChangeNotifier {
  final UserService _userService = UserService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  String? user_id;

  String? selectedAge;
  String? selectedWeight;
  String? selectedHeight;
  String? selectedGender;
  String? selectedDisease;
  String? selectedAllergy;

  bool isVegetarianOriginal = false;
  bool isVegetarianTemp = false;

  bool get isVegetarian => isVegetarianTemp;
  set isVegetarian(bool value) {
    isVegetarianTemp = value;
    notifyListeners();
  }

  bool isLoading = false;
  bool isEditing = false;
  bool obscurePassword = true;

  String? _oldPasswordHash;

  SettingsController() {
    loadUserId(); // load from SharedPreferences
  }

  Future<void> loadUserId() async {
    isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    user_id = prefs.getString('userId'); // Stored as string from FirebaseAuth

    if (user_id?.isEmpty ?? true) {
      isLoading = false;
      notifyListeners();
      return;
    }

    await fetchUser();
  }

  Future<void> fetchUser() async {
    if (user_id == null) return;

    final user = await _userService.getUserById(user_id!);

    if (user == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    nameController.text = user.name;
    emailController.text = user.email;
    _oldPasswordHash = user.passwordHash;
    bioController.text = user.Bio;

    selectedAge = user.Age.toString();
    selectedWeight = user.Weight.toString();
    selectedHeight = user.Height.toString();
    selectedGender = user.Gender;
    selectedDisease = user.Diseases;
    selectedAllergy = user.specificAllergies;

    isVegetarianOriginal = user.isVegetarian;
    isVegetarianTemp = user.isVegetarian;

    isLoading = false;
    notifyListeners();
  }

  Future<void> saveUserData(BuildContext context) async {
    if (user_id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Save"),
        content: const Text("Are you sure you want to save changes?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Save")),
        ],
      ),
    );

    if (confirmed != true) return;

    isLoading = true;
    notifyListeners();

    try {
      final newPassword = passwordController.text.isNotEmpty
          ? hashPassword(passwordController.text)
          : _oldPasswordHash ?? '';

      final user = UserModel(
        user_id: user_id!,
        name: nameController.text,
        email: emailController.text,
        Bio: bioController.text,
        Gender: selectedGender ?? '',
        Age: int.tryParse(selectedAge ?? '0') ?? 0,
        Height: int.tryParse(selectedHeight ?? '0') ?? 0,
        Weight: int.tryParse(selectedWeight ?? '0') ?? 0,
        Diseases: selectedDisease ?? '',
        specificAllergies: selectedAllergy ?? '',
        isVegetarian: isVegetarianTemp,
        passwordHash: newPassword,
      );

      await _userService.updateUser(user);
      await _userService.saveUserCalories(user);

      //  إرسال إشعار للمستخدم
      await NotificationsController().createNotification(
        userId: user_id!,
        message: 'Your profile has been updated successfully.',
        type: 'profileUpdate',
      );

      isVegetarianOriginal = isVegetarianTemp;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Changes saved successfully")),
      );

      isEditing = false;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String hashPassword(String password) {
    return password; // Stub for now
  }

  void toggleEditing() {
    isEditing = !isEditing;
    if (isEditing) {
      isVegetarianTemp = isVegetarianOriginal;
    }
    notifyListeners();
  }

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }
}
