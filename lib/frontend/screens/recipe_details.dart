import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

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
  int selectedTabIndex = 0;

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String selectedMeal = "Breakfast";

  static const String apiKey = 'eaf8e536e30445a4b4862cdcaa7dbb0f';
  static const String ytApiKey = 'AIzaSyAn4XdXyZ-hLagS-je_kMEXw2M1afcajJ4'; // ضع مفتاح YouTube API الخاص بك هنا

  bool isLoading = false;
  List<String> ingredients = [];
  String? videoUrl;
  String? youtubeVideoId;

  double protein = 0;
  double fat = 0;
  double carbs = 0;
  double fiber = 0;

  @override
  void initState() {
    super.initState();
    fetchRecipeDetails();
  }

  Future<void> fetchRecipeDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      final recipeId = widget.recipe['id'];
      if (recipeId == null) throw Exception('Recipe ID not found');

      final url = Uri.parse(
          'https://api.spoonacular.com/recipes/$recipeId/information?apiKey=$apiKey&includeNutrition=true');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final ingredientsData = data['extendedIngredients'] ?? [];
        final fetchedIngredients = ingredientsData
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
          }
        }

        setState(() {
          ingredients = fetchedIngredients;
          videoUrl = data['sourceUrl'];
        });

        await fetchYouTubeVideo(widget.recipe['title'] ?? '');
      } else {
        throw Exception('Failed to load recipe');
      }
    } catch (e) {
      print("Error: $e");
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
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'];
        if (items != null && items.isNotEmpty) {
          setState(() {
            youtubeVideoId = items[0]['id']['videoId'];
          });
        }
      }
    } catch (e) {
      print('YouTube video fetch error: $e');
    }
  }

  void _showScheduleDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Schedule Recipe"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () => _selectDate(context),
                child: const Text("Pick Date"),
              ),
              ElevatedButton(
                onPressed: () => _selectTime(context),
                child: const Text("Pick Time"),
              ),
              DropdownButton<String>(
                value: selectedMeal,
                onChanged: (value) {
                  setState(() {
                    selectedMeal = value!;
                  });
                },
                items: ['Breakfast', 'Lunch', 'Dinner', 'Snack']
                    .map((meal) => DropdownMenuItem<String>(
                  value: meal,
                  child: Text(meal),
                ))
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                saveScheduledRecipe();
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void saveScheduledRecipe() {
    final DateTime scheduledDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    FirebaseFirestore.instance.collection('scheduled_recipes').add({
      'recipe': widget.recipe,
      'scheduledDateTime': scheduledDateTime.toIso8601String(),
      'meal': selectedMeal,
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked =
    await showTimePicker(context: context, initialTime: selectedTime);
    if (picked != null) setState(() => selectedTime = picked);
  }

  void _launchVideo(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the video')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final imageUrl = recipe['image_url'] ?? recipe['image'] ?? '';

    if (selectedTabIndex == 1) {
      Future.microtask(() {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => IngredientsPage(recipeId: widget.recipe['id']),
          ),
        ).then((_) {
          setState(() {
            selectedTabIndex = 0;
          });
        });
      });
    }

    if (selectedTabIndex == 2) {
      Future.microtask(() {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StepsPage(recipeId: widget.recipe['id']),
          ),
        ).then((_) {
          setState(() {
            selectedTabIndex = 0;
          });
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {},
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
            recipe['title'] ?? "Recipe Name",
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold),
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
                  selectedTabIndex == 0
                      ? (youtubeVideoId != null
                      ? ElevatedButton.icon(
                    onPressed: () => _launchVideo(
                        'https://www.youtube.com/watch?v=$youtubeVideoId'),
                    icon:
                    const Icon(Icons.play_circle_fill),
                    label: const Text("Watch Video"),
                  )
                      : const Text("No related video found"))
                      : Container(),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Nutrition Information",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
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
                      _buildNutritionBar("Protein", protein.toInt(), 100,
                          Colors.orangeAccent),
                      _buildNutritionBar("Fat", fat.toInt(), 100,
                          Colors.redAccent),
                      _buildNutritionBar("Carbs", carbs.toInt(), 100,
                          Colors.blueAccent),
                      _buildNutritionBar("Fiber", fiber.toInt(), 100,
                          Colors.greenAccent),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (selectedTabIndex == 0)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[200],
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 15),
                ),
                onPressed: _showScheduleDialog,
                child: const Text("Add to Meal Plan"),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNutritionBar(
      String label, int value, int maxValue, Color color) {
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
              width: (value / maxValue) *
                  (MediaQuery.of(context).size.width - 72) /
                  2,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTab(int index, String title, Color bgColor) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedTabIndex = index;
          });
        },
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(5),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
