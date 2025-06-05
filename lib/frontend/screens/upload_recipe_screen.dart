import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/NavigationBar.dart';
import '../widgets/notification_bell.dart';
import '../../backend/models/recipe_model.dart';
import 'add_ingredients_screen.dart';
import '../../backend/controllers/upload_recipe_controller.dart';

class UploadRecipeScreen extends StatefulWidget {
  const UploadRecipeScreen({super.key});

  @override
  State<UploadRecipeScreen> createState() => _UploadRecipeScreenState();
}

class _UploadRecipeScreenState extends State<UploadRecipeScreen> {
  final List<String> recipeTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
  List<bool> selectedTypes = [true, false, false, false];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController stepsController = TextEditingController();

  List<Map<String, dynamic>> selectedIngredients = [];
  DateTime? selectedDate;
  File? imageFile;
  String? user_id;

  final RecipeController _recipeController = RecipeController();

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('userId');
    if (id == null || id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID does not exist. Please login again.')),
      );
    } else {
      setState(() {
        user_id = id;
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _addIngredient() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddIngredientsScreen()),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        final exists = selectedIngredients.any((item) => item['name'] == result['name']);
        if (!exists) selectedIngredients.add(result);
      });
    }
  }

  Future<void> _pickImage() async {
    final status = await Permission.photos.request();
    final storageStatus = await Permission.storage.request();

    if (status.isGranted || storageStatus.isGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          imageFile = File(pickedFile.path);
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gallery access denied.')),
      );
    }
  }

  Future<void> uploadRecipe() async {
    final selectedType = recipeTypes[selectedTypes.indexWhere((e) => e)];

    if (user_id == null || user_id!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID is missing. Please log in again.')),
      );
      return;
    }

    final recipe = Recipe(
      user_id: user_id!,
      title: nameController.text.trim(),
      steps: stepsController.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      Ingredients: selectedIngredients,
      type: selectedType,
      date: selectedDate,
      calories: 0,
      protein: 0,
      carbs: 0,
      fats: 0,


    );

    try {
      await _recipeController.uploadRecipe(recipe, imageFile);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe uploaded successfully!')),
      );

      setState(() {
        nameController.clear();
        stepsController.clear();
        selectedIngredients.clear();
        selectedTypes = [true, false, false, false];
        selectedDate = null;
        imageFile = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload recipe: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Recipe'),
        centerTitle: true,
        actions: [NotificationBell(unreadCount: 5)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: imageFile != null
                  ? Image.file(imageFile!, height: 150)
                  : const Icon(Icons.image_outlined, size: 100, color: Colors.grey),
            ),
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.upload),
              label: const Text('Upload Image'),
            ),
            const SizedBox(height: 16),
            const Text('Recipe Name'),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Add Name'),
            ),
            const SizedBox(height: 10),
            const Text('Ingredients'),
            Wrap(
              spacing: 8.0,
              children: selectedIngredients.map((ingredient) {
                return Chip(
                  label: Text(ingredient['name'] ?? 'Unknown'),
                  onDeleted: () {
                    setState(() {
                      selectedIngredients.remove(ingredient);
                    });
                  },
                );
              }).toList(),
            ),
            TextButton.icon(
              onPressed: _addIngredient,
              icon: const Icon(Icons.add),
              label: const Text('Add Ingredient'),
            ),
            const SizedBox(height: 10),
            const Text('Steps'),
            TextField(
              controller: stepsController,
              minLines: 3,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'Step 1...\nStep 2...\nStep 3...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            const Text('Recipe Type'),
            ToggleButtons(
              borderRadius: BorderRadius.circular(20),
              isSelected: selectedTypes,
              onPressed: (index) {
                setState(() {
                  for (int i = 0; i < selectedTypes.length; i++) {
                    selectedTypes[i] = i == index;
                  }
                });
              },
              children: recipeTypes.map((type) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(type),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Date'),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  selectedDate != null
                      ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                      : 'Select Date',
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: (nameController.text.trim().isEmpty ||
                  stepsController.text.trim().isEmpty ||
                  selectedIngredients.isEmpty ||
                  user_id == null)
                  ? null
                  : uploadRecipe,
              child: const Text('Upload Recipe'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }
}
