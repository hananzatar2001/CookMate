/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../frontend/widgets/custom_save_button.dart';
 import 'package:cookmate/frontend/widgets/NavigationBar.dart';
import 'Steps_Page.dart';
import 'Ingredients_Page.dart';

class RecipeDetailsPage extends StatefulWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailsPage({super.key, required this.recipe});

  @override
  State<RecipeDetailsPage> createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> {
  bool isSaved = false;
  String? savedRecipeDocId;
  int selectedTabIndex = 0;

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String selectedMeal = "Breakfast";

  static const String apiKey = 'eaf8e536e30445a4b4862cdcaa7dbb0f';
  static const String ytApiKey = 'AIzaSyAn4XdXyZ-hLagS-je_kMEXw2M1afcajJ4';

  bool isLoading = false;
  List<String> ingredients = [];
  String? videoUrl;
  String? youtubeVideoId;

  double protein = 0;
  double fat = 0;
  double carbs = 0;
  double fiber = 0;

  String? user_id;

  @override
  void initState() {
    super.initState();
    fetchRecipeDetails();
    checkIfRecipeSaved();
    loadUserId(); // Load userId from SharedPreferences
  }

  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      user_id = prefs.getString('userId');
    });
  }

  Future<void> checkIfRecipeSaved() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('SaveRecipes')
        .where('recipe.id', isEqualTo: widget.recipe['id'])
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        isSaved = true;
        savedRecipeDocId = snapshot.docs.first.id;
      });
    }
  }

  Future<void> fetchRecipeDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      final recipeId = widget.recipe['id'];
      final url = Uri.parse(
          'https://api.spoonacular.com/recipes/$recipeId/information?apiKey=$apiKey&includeNutrition=true');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final ingredientsData = data['extendedIngredients'] ?? [];
        ingredients = ingredientsData
            .map<String>((item) => item['original'].toString())
            .toList();

        final nutrients = data['nutrition']['nutrients'] ?? [];
        for (var item in nutrients) {
          switch (item['name']) {
            case 'Protein':
              protein = item['amount']?.toDouble() ?? 0;
              break;
            case 'Fat':
              fat = item['amount']?.toDouble() ?? 0;
              break;
            case 'Carbohydrates':
              carbs = item['amount']?.toDouble() ?? 0;
              break;
            case 'Fiber':
              fiber = item['amount']?.toDouble() ?? 0;
              break;
            case 'Calories':
              widget.recipe['calories'] = item['amount']?.toDouble() ?? 0;
              break;
          }
        }

        videoUrl = data['sourceUrl'];
        await fetchYouTubeVideo(widget.recipe['title'] ?? '');
      }
    } catch (e) {
      print("Error fetching recipe: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchYouTubeVideo(String query) async {
    final url = Uri.parse(
        'https://www.googleapis.com/youtube/v3/search?part=snippet&q=${Uri.encodeComponent(query)}&type=video&maxResults=1&key=$ytApiKey');

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);
      final items = data['items'];
      if (items != null && items.isNotEmpty) {
        youtubeVideoId = items[0]['id']['videoId'];
        setState(() {});
      }
    } catch (e) {
      print('YouTube fetch error: $e');
    }
  }

  void handleSaveOrDelete() async {
    if (user_id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in to save a recipe")),
      );
      return;
    }

    if (isSaved && savedRecipeDocId != null) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Delete Confirmation"),
          content: const Text("Are you sure you want to delete this recipe from SaveRecipes?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete")),
          ],
        ),
      );

      if (confirm == true) {
        await FirebaseFirestore.instance
            .collection('SaveRecipes')
            .doc(savedRecipeDocId!)
            .delete();
        setState(() {
          isSaved = false;
          savedRecipeDocId = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Recipe removed from SaveRecipes")),
        );
      }
    } else {
      final doc = await FirebaseFirestore.instance.collection('SaveRecipes').add({
        'userId': user_id,
        'recipe': widget.recipe,
        'ingredients': ingredients,
        'protein': protein,
        'fat': fat,
        'carbs': carbs,
        'fiber': fiber,
        'savedAt': DateTime.now().toIso8601String(),
      });

      setState(() {
        isSaved = true;
        savedRecipeDocId = doc.id;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Recipe saved to SaveRecipes")),
      );
    }
  }

  void _launchVideo(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the video')),
      );
    }
  }

  void _showMealPlanBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CalendarDatePicker(
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                onDateChanged: (date) {
                  setState(() => selectedDate = date);
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text("Ends"),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      final time = await showTimePicker(
                          context: context, initialTime: selectedTime);
                      if (time != null) {
                        setState(() => selectedTime = time);
                      }
                    },
                    child: Text(selectedTime.format(context)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ["Breakfast", "Lunch", "Dinner", "Snacks"]
                    .map((meal) => ChoiceChip(
                  label: Text(meal),
                  selected: selectedMeal == meal,
                  onSelected: (_) {
                    setState(() => selectedMeal = meal);
                  },
                ))
                    .toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  Future.delayed(const Duration(milliseconds: 300), () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Recipe added to Meal Plan")),
                    );
                  });

                  if (user_id == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("You must be logged in to add to Meal Plan")),
                    );
                    return;
                  }

                  try {
                    final mealDateTime = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );

                    await FirebaseFirestore.instance.collection('MealPlans').add({
                      'userId': user_id,
                      'recipe': widget.recipe,
                      'mealType': selectedMeal,
                      'dateTime': mealDateTime.toIso8601String(),
                      'addedAt': DateTime.now().toIso8601String(),
                      'nutrition': {
                        'protein': protein,
                        'fat': fat,
                        'carbs': carbs,
                        'fiber': fiber,
                        'calories': widget.recipe['calories'] ?? 0,
                      },
                    });
                  } catch (e) {
                    print('Error saving to MealPlans: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to save to Meal Plan")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF47551),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
                child: const Text("Save", style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final imageUrl = recipe['image_url'] ?? recipe['image'] ?? '';

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        actions: [
          CustomSaveButton(
            isSaved: isSaved,
            onPressed: handleSaveOrDelete,
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : buildContent(context, imageUrl),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: selectedTabIndex),
    );
  }

  Widget buildContent(BuildContext context, String imageUrl) {
    return Column(
      children: [
        Image.network(
          imageUrl,
          height: 180,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
          const Center(child: Icon(Icons.broken_image)),
        ),
        const SizedBox(height: 8),
        Text(
          widget.recipe['title'] ?? "Recipe Name",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildTab(0, "Video", Colors.amber[200]!),
            _buildTab(1, "Ingredients", Colors.green[100]!),
            _buildTab(2, "Steps", Colors.purple[100]!),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (selectedTabIndex == 0)
                  (youtubeVideoId != null
                      ? ElevatedButton(
                    onPressed: () => _launchVideo(
                        'https://www.youtube.com/watch?v=$youtubeVideoId'),
                    child: const Text("Watch Video"),
                  )
                      : const Text("No related video found")),
                const SizedBox(height: 24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Nutrition Information",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 3,
                  children: [
                    _buildNutritionBar("Protein", protein.toInt(), 100, Colors.orangeAccent),
                    _buildNutritionBar("Fat", fat.toInt(), 100, Colors.redAccent),
                    _buildNutritionBar("Carbs", carbs.toInt(), 100, Colors.blueAccent),
                    _buildNutritionBar("Fiber", fiber.toInt(), 100, Colors.greenAccent),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _showMealPlanBottomSheet,
                  child: const Text("Add to Meal Plan"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF47551),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionBar(String label, int value, int maxValue, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: $value g"),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              width: (MediaQuery.of(context).size.width - 72) / 2,
              height: 12,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(6)),
            ),
            Container(
              width: (value / maxValue) * (MediaQuery.of(context).size.width - 72) / 2,
              height: 12,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(6)),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildTab(int index, String label, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              selectedTabIndex = index;
            });

            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        IngredientsPage(recipeId: widget.recipe['id'])),
              ).then((_) {
                setState(() => selectedTabIndex = 0);
              });
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        StepsPage(recipeId: widget.recipe['id'])),
              ).then((_) {
                setState(() => selectedTabIndex = 0);
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight:
                  selectedTabIndex == index ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:cookmate/frontend/widgets/custom_save_button.dart';
import 'package:cookmate/frontend/widgets/NavigationBar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'Ingredients_Page.dart';
import 'Steps_Page.dart';
import '../../backend/controllers/recipe_controller.dart';

class RecipeDetailsPage extends StatefulWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailsPage({super.key, required this.recipe});

  @override
  State<RecipeDetailsPage> createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> {
  late RecipeDetailsController controller;
  int selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    controller = RecipeDetailsController(recipe: widget.recipe);
    controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    controller.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final imageUrl = recipe['image_url'] ?? recipe['image'] ?? '';

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        actions: [
          CustomSaveButton(
            isSaved: controller.isSaved,
            onPressed: () async {
              final result = await controller.saveOrDeleteRecipe();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Recipe $result')),
              );
            },
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : buildContent(context, imageUrl),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: selectedTabIndex),
    );
  }

  Widget buildContent(BuildContext context, String imageUrl) {
    return Column(
      children: [
        Image.network(
          imageUrl,
          height: 180,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
          const Center(child: Icon(Icons.broken_image)),
        ),
        const SizedBox(height: 8),
        Text(
          widget.recipe['title'] ?? "Recipe Name",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildTab(0, "Video", Colors.amber[200]!),
            _buildTab(1, "Ingredients", Colors.green[100]!),
            _buildTab(2, "Steps", Colors.purple[100]!),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (selectedTabIndex == 0)
                  (controller.youtubeVideoId != null
                      ? ElevatedButton(
                    onPressed: () => _launchVideo(
                        'https://www.youtube.com/watch?v=${controller.youtubeVideoId}'),
                    child: const Text("Watch Video"),
                  )
                      : const Text("No related video found")),
                const SizedBox(height: 24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Nutrition Information",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 3,
                  children: [
                    _buildNutritionBar(
                        "Protein", controller.protein.toInt(), 100, Colors.orangeAccent),
                    _buildNutritionBar(
                        "Fat", controller.fat.toInt(), 100, Colors.redAccent),
                    _buildNutritionBar(
                        "Carbs", controller.carbs.toInt(), 100, Colors.blueAccent),
                    _buildNutritionBar(
                        "Fiber", controller.fiber.toInt(), 100, Colors.greenAccent),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    showMealPlanBottomSheet(context);
                  },
                  child: const Text("Add to Meal Plan"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF47551),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionBar(String label, int value, int maxValue, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: $value g"),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              width: (MediaQuery.of(context).size.width - 72) / 2,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            Container(
              width: (value / maxValue) * (MediaQuery.of(context).size.width - 72) / 2,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildTab(int index, String label, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: () {
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => IngredientsPage(recipeId: widget.recipe['id'])),
              ).then((_) {
                setState(() => selectedTabIndex = 0);
              });
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => StepsPage(recipeId: widget.recipe['id'])),
              ).then((_) {
                setState(() => selectedTabIndex = 0);
              });
            } else {
              setState(() {
                selectedTabIndex = index;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight:
                  selectedTabIndex == index ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _launchVideo(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the video')),
      );
    }
  }

  void showMealPlanBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // التاريخ
              Row(
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 8),
                  Text("Date: ${DateFormat.yMMMd().format(controller.selectedDate)}"),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: controller.selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (pickedDate != null) {
                        setState(() => controller.selectedDate = pickedDate);
                      }
                    },
                    child: const Text("Change"),
                  ),
                ],
              ),

              // الوقت
              Row(
                children: [
                  const Icon(Icons.access_time),
                  const SizedBox(width: 8),
                  Text("Time: ${controller.selectedTime.format(context)}"),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: controller.selectedTime,
                      );
                      if (pickedTime != null) {
                        setState(() => controller.selectedTime = pickedTime);
                      }
                    },
                    child: const Text("Change"),
                  ),
                ],
              ),

              // نوع الوجبة
              DropdownButtonFormField<String>(
                value: controller.selectedMeal,
                items: const [
                  DropdownMenuItem(value: "Breakfast", child: Text("Breakfast")),
                  DropdownMenuItem(value: "Lunch", child: Text("Lunch")),
                  DropdownMenuItem(value: "Dinner", child: Text("Dinner")),
                  DropdownMenuItem(value: "Snack", child: Text("Snack")),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => controller.selectedMeal = val);
                  }
                },
                decoration: const InputDecoration(
                  labelText: "Meal Type",
                  prefixIcon: Icon(Icons.restaurant_menu),
                ),
              ),

              const SizedBox(height: 16),

              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Save to Meal Plan"),
                onPressed: () async {
                  final result = await controller.addToMealPlan();
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Meal Plan: $result")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF47551),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

