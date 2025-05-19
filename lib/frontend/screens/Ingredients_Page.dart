import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:cook_mate/frontend/widgets/notification_bell.dart';

class IngredientsPage extends StatefulWidget {
  final int recipeId;

  const IngredientsPage({super.key, required this.recipeId});

  @override
  State<IngredientsPage> createState() => _IngredientsPageState();
}

class _IngredientsPageState extends State<IngredientsPage> {
  static const String apiKey = 'eaf8e536e30445a4b4862cdcaa7dbb0f';

  bool isLoading = true;
  String error = '';
  List<String> ingredients = [];
  List<bool> checked = [];

  // هنا عداد الإشعارات الغير مقروءة (مثال)
  int unreadCount = 0;

  @override
  void initState() {
    super.initState();
    fetchIngredients();
    // ممكن هنا تجلب عدد الإشعارات الحقيقية
  }

  Future<void> fetchIngredients() async {
    try {
      final url = Uri.parse(
        'https://api.spoonacular.com/recipes/${widget.recipeId}/information?apiKey=$apiKey&includeNutrition=false',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final ingredientsData = data['extendedIngredients'] ?? [];
        final List<String> fetchedIngredients = ingredientsData
            .map<String>((item) => item['original'].toString())
            .toList();

        setState(() {
          ingredients = fetchedIngredients;
          checked = List<bool>.filled(fetchedIngredients.length, false);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load ingredients');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredients'),
        actions: [
          NotificationBell(unreadCount: unreadCount),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
          ? Center(child: Text(error))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ingredients.length,
        itemBuilder: (context, index) {
          final isChecked = checked[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 3,
            color: isChecked ? Colors.green[100] : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Checkbox(
                value: isChecked,
                onChanged: (bool? value) {
                  setState(() {
                    checked[index] = value ?? false;
                  });
                },
              ),
              title: Text(
                ingredients[index],
                style: const TextStyle(fontSize: 15),
              ),
            ),
          );
        },
      ),
    );
  }
}
