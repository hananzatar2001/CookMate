import 'package:flutter/material.dart';
import 'app_database.dart';
import 'user/user.dart';

class SettingsViewModel {
  final AppDatabase _database;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  int age = 18;
  int weight = 180;
  String gender = 'female';
  int height = 180;
  String? selectedDisease;
  String? selectedAllergy;
  bool isVegetarian = false;

  User? _currentUser;

  SettingsViewModel(this._database) {
    _loadUserData();
  }

  void _loadUserData() {
    _currentUser = _database.currentUser;

    if (_currentUser != null) {
      nameController.text = _currentUser!.name;
      emailController.text = _currentUser!.email;
      passwordController.text = '******';

      age = _currentUser!.age;
      weight = _currentUser!.weight;
      gender = _currentUser!.gender;
      height = _currentUser!.height;
      selectedDisease = _currentUser!.disease;
      selectedAllergy = _currentUser!.allergy;
      isVegetarian = _currentUser!.isVegetarian;
    }
  }

  Future<void> saveUserSettings() async {
    if (_currentUser == null) return;

    final updatedUser = User(
      id: _currentUser!.id,
      name: nameController.text,
      email: emailController.text,

      password:
          passwordController.text == '******'
              ? _currentUser!.password
              : passwordController.text,
      dailyCalorieTarget: _currentUser!.dailyCalorieTarget,
      dailyProteinTarget: _currentUser!.dailyProteinTarget,
      dailyCarbsTarget: _currentUser!.dailyCarbsTarget,
      dailyFatTarget: _currentUser!.dailyFatTarget,
      dailyFiberTarget: _currentUser!.dailyFiberTarget,
      age: age,
      weight: weight,
      gender: gender,
      height: height,
      disease: selectedDisease,
      allergy: selectedAllergy,
      isVegetarian: isVegetarian,
    );

    await _database.setUser(updatedUser);
  }

  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
  }
}
