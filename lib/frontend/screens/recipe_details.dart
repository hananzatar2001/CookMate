import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecipeDetailsPage extends StatefulWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailsPage({super.key, required this.recipe});

  @override
  State<RecipeDetailsPage> createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> {
  bool isSaved = false;

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String selectedMeal = "Breakfast";

  static const String apiKey = '5cbc633fbbd840a29f5a29225a1ad55f';

  bool isLoading = false;
  List<String> ingredients = [];
  List<String> steps = [];
  String? videoUrl;

  int selectedTabIndex = 0;

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
          'https://api.spoonacular.com/recipes/$recipeId/information?apiKey=$apiKey&includeNutrition=false');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final ingredientsData = data['extendedIngredients'] as List<dynamic>? ?? [];
        final stepsData = (data['analyzedInstructions'] != null &&
            data['analyzedInstructions'].isNotEmpty)
            ? (data['analyzedInstructions'][0]['steps'] as List<dynamic>)
            : [];

        final fetchedIngredients = ingredientsData
            .map((item) => item['original']?.toString() ?? 'Unknown Ingredient')
            .toList();

        final fetchedSteps =
        stepsData.map((step) => step['step']?.toString() ?? '').toList();

        setState(() {
          ingredients = fetchedIngredients;
          steps = fetchedSteps;
          videoUrl = null;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch recipe info: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching recipe details: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked =
    await showTimePicker(context: context, initialTime: selectedTime);
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
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
              Text("Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
              ElevatedButton(
                onPressed: () => _selectDate(context),
                child: const Text("Pick Date"),
              ),
              Text("Time: ${selectedTime.format(context)}"),
              ElevatedButton(
                onPressed: () => _selectTime(context),
                child: const Text("Pick Time"),
              ),
              DropdownButton<String>(
                value: selectedMeal,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedMeal = newValue!;
                  });
                },
                items: <String>['Breakfast', 'Lunch', 'Dinner', 'Snack']
                    .map<DropdownMenuItem<String>>(
                        (String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ))
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                saveScheduledRecipe();
                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void saveScheduledRecipe() {
    final scheduledDateTime = DateTime(
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
    }).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe scheduled successfully!')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to schedule recipe.')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['title'] ?? 'Recipe Details'),
        actions: [
          IconButton(
            icon: Icon(isSaved ? Icons.favorite : Icons.favorite_border),
            onPressed: () {
              setState(() {
                isSaved = !isSaved;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.schedule),
            onPressed: _showScheduleDialog,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          if (recipe['image'] != null)
            Image.network(recipe['image']),
          TabBarWidget(
            selectedIndex: selectedTabIndex,
            onTabSelected: (index) {
              setState(() {
                selectedTabIndex = index;
              });
            },
          ),
          Expanded(
            child: selectedTabIndex == 0
                ? ListView(
              padding: const EdgeInsets.all(8),
              children: ingredients
                  .map((ingredient) => ListTile(
                leading: const Icon(Icons.kitchen),
                title: Text(ingredient),
              ))
                  .toList(),
            )
                : ListView(
              padding: const EdgeInsets.all(8),
              children: steps
                  .asMap()
                  .entries
                  .map((entry) => ListTile(
                leading: CircleAvatar(
                  child: Text('${entry.key + 1}'),
                ),
                title: Text(entry.value),
              ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class TabBarWidget extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  const TabBarWidget({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildTab(context, 0, 'Ingredients'),
        _buildTab(context, 1, 'Steps'),
      ],
    );
  }

  Widget _buildTab(BuildContext context, int index, String label) {
    final isSelected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
