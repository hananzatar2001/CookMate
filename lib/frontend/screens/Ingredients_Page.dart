import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/NavigationBar.dart';

class IngredientsPage extends StatefulWidget {
  final dynamic recipeId; // String for Firestore, int for API

  const IngredientsPage({super.key, required this.recipeId});

  @override
  State<IngredientsPage> createState() => _IngredientsPageState();
}

class _IngredientsPageState extends State<IngredientsPage> {
  static const String apiKey = '747c317616f247b79c6d9067afde371c';
//
  bool isLoading = true;
  String error = '';
  List<String> ingredients = [];
  List<String> substitutes = [];
  List<bool> checked = [];

  @override
  void initState() {
    super.initState();
    fetchIngredients();
  }

  Future<void> fetchIngredients() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    if (widget.recipeId is String) {
      await fetchIngredientsFromFirestore(widget.recipeId);
    } else if (widget.recipeId is int) {
      await fetchIngredientsFromApi(widget.recipeId);
    } else {
      setState(() {
        error = 'Invalid recipe ID type';
        isLoading = false;
      });
    }
  }

  Future<void> fetchIngredientsFromFirestore(String docId) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance.collection('Recipes').doc(docId).get();

      if (!docSnapshot.exists) {
        setState(() {
          error = 'Recipe not found in Firestore';
          isLoading = false;
        });
        return;
      }

      final data = docSnapshot.data() as Map<String, dynamic>;

      if (data.containsKey('Ingredients') && data['Ingredients'] is List) {
        final List<String> fetchedIngredients =
        (data['Ingredients'] as List).map((e) => e.toString()).toList();

        setState(() {
          ingredients = fetchedIngredients;
          substitutes = List<String>.filled(fetchedIngredients.length, ''); // Firestore has no substitutes
          checked = List<bool>.filled(fetchedIngredients.length, false);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Ingredients field is missing or invalid in the recipe.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error fetching from Firestore: $e';
        isLoading = false;
      });
    }
  }

  Future<void> fetchIngredientsFromApi(int id) async {
    try {
      final url = Uri.parse(
          'https://api.spoonacular.com/recipes/$id/information?apiKey=$apiKey&includeNutrition=false');
      final response = await http.get(url);

      if (response.statusCode != 200) {
        setState(() {
          error = 'Failed to load ingredients from API';
          isLoading = false;
        });
        return;
      }

      final data = json.decode(response.body);

      if (data.containsKey('extendedIngredients') && data['extendedIngredients'] is List) {
        final List<dynamic> apiIngredients = data['extendedIngredients'];
        final List<String> fetchedIngredients =
        apiIngredients.map<String>((ing) => ing['original'].toString()).toList();

        final List<String> names =
        apiIngredients.map<String>((ing) => ing['name'].toString()).toList();

        final List<String> fetchedSubstitutes = await fetchSubstitutesForAll(names);

        setState(() {
          ingredients = fetchedIngredients;
          substitutes = fetchedSubstitutes;
          checked = List<bool>.filled(fetchedIngredients.length, false);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Ingredients data missing or invalid from API.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error fetching from API: $e';
        isLoading = false;
      });
    }
  }

  Future<List<String>> fetchSubstitutesForAll(List<String> names) async {
    List<String> result = [];

    for (var name in names) {
      final sub = await fetchSubstitute(name);
      result.add(sub);
    }

    return result;
  }

  Future<String> fetchSubstitute(String ingredientName) async {
    try {
      final url = Uri.parse(
          'https://api.spoonacular.com/food/ingredients/substitutes?apiKey=$apiKey&ingredientName=${Uri.encodeComponent(ingredientName)}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success' && data['substitutes'] != null) {
          final List<dynamic> subs = data['substitutes'];
          return subs.isNotEmpty ? subs[0].toString() : 'No substitute found';
        }
      }
    } catch (_) {}

    return 'No substitute found';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredients'),
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
              subtitle: Text(
                'Substitute: ${substitutes[index]}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: -1),

    );
  }
}
