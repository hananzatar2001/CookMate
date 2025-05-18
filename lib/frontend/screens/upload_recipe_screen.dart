
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'add_ingredients_screen.dart';
import 'package:cook_mate/backend/services/RecipeService.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../../frontend/widgets/NavigationBar.dart';


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

  List<String> selectedIngredients = [];

  DateTime? selectedDate;
  File? imageFile;

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

    if (result != null && result is String) {
      setState(() {
        if (!selectedIngredients.contains(result)) {
          selectedIngredients.add(result);
        }
      });
    }
  }

  final RecipeService _recipeService = RecipeService();




  Future<String?> uploadImageToCloudinary(File imageFile) async {
    const cloudName = 'dobduqtmi';
    const uploadPreset = 'CookMate';

    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final mimeTypeData = lookupMimeType(imageFile.path)?.split('/');

    final imageUploadRequest = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType: mimeTypeData != null
              ? MediaType(mimeTypeData[0], mimeTypeData[1])
              : null,
        ),
      );

    final response = await imageUploadRequest.send();

    if (response.statusCode == 200) {
      final resString = await response.stream.bytesToString();
      final Map<String, dynamic> resData = json.decode(resString);
      return resData['secure_url'];
    } else {
      print('Cloudinary upload failed: ${response.statusCode}');
      return null;
    }
  }


  Future<void> uploadRecipe() async {
    final selectedType = recipeTypes[selectedTypes.indexWhere((e) => e)];

    try {
      String? imageUrl;

      if (imageFile != null) {
        imageUrl = await uploadImageToCloudinary(imageFile!);
        if (imageUrl == null) {
          throw Exception('Failed to upload image to Supabase');
        }
      }


      await _recipeService.uploadRecipe(
        userId: 'vhanan',
        recipeId: 'hanan',
        title: nameController.text.trim(),
        steps: stepsController.text
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        ingredients: selectedIngredients,
        recipeType: selectedType,
        imageUrl: imageUrl,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe uploaded successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload recipe: $e')),
      );
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
    } else if (status.isPermanentlyDenied || storageStatus.isPermanentlyDenied) {
      openAppSettings();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable gallery access from settings.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gallery access denied.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Recipe'),
        centerTitle: true,
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
                  label: Text(ingredient),
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
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: uploadRecipe,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Upload Recipe'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 5),

    );
  }
}

