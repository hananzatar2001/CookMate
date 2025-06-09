import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class StepsPage extends StatefulWidget {
  final dynamic recipeId; // int for API, String for Firestore

  const StepsPage({super.key, required this.recipeId});

  @override
  State<StepsPage> createState() => _StepsPageState();
}

class _StepsPageState extends State<StepsPage> {
  static const String apiKey = '7522e29d3dc44b16bfb34d94f5d331bb';

  bool isLoading = true;
  String error = '';
  List<String> steps = [];
  List<bool> checkedSteps = [];

  @override
  void initState() {
    super.initState();
    fetchSteps();
  }

  Future<void> fetchSteps() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    if (widget.recipeId is String) {
      await fetchStepsFromFirestore(widget.recipeId);
    } else if (widget.recipeId is int) {
      await fetchStepsFromApi(widget.recipeId);
    } else {
      setState(() {
        error = 'Invalid recipe ID type';
        isLoading = false;
      });
    }
  }

  Future<void> fetchStepsFromFirestore(String docId) async {
    try {
      final docSnapshot =
      await FirebaseFirestore.instance.collection('Recipes').doc(docId).get();

      if (!docSnapshot.exists) {
        setState(() {
          error = 'Recipe not found in Firestore';
          isLoading = false;
        });
        return;
      }

      final data = docSnapshot.data() as Map<String, dynamic>;

      List<String> fetchedSteps = [];
      if (data.containsKey('steps') && data['steps'] is List) {
        fetchedSteps = (data['steps'] as List).map((e) => e.toString()).toList();
      }

      setState(() {
        steps = fetchedSteps;
        checkedSteps = List<bool>.filled(steps.length, false);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error fetching steps from Firestore: $e';
        isLoading = false;
      });
    }
  }

  Future<void> fetchStepsFromApi(int id) async {
    try {
      final url = Uri.parse(
          'https://api.spoonacular.com/recipes/$id/information?apiKey=$apiKey&includeNutrition=false');
      final response = await http.get(url);

      if (response.statusCode != 200) {
        setState(() {
          error = 'Failed to load data from API';
          isLoading = false;
        });
        return;
      }

      final data = json.decode(response.body);

      List<String> fetchedSteps = [];
      final stepsData = (data['analyzedInstructions'] != null &&
          (data['analyzedInstructions'] as List).isNotEmpty)
          ? data['analyzedInstructions'][0]['steps']
          : [];
      fetchedSteps =
          (stepsData as List).map<String>((s) => s['step'].toString()).toList();

      setState(() {
        steps = fetchedSteps;
        checkedSteps = List<bool>.filled(steps.length, false);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error fetching steps from API: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Steps'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
          ? Center(child: Text(error))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: steps.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: Checkbox(
                value: checkedSteps[index],
                onChanged: (val) {
                  setState(() {
                    checkedSteps[index] = val ?? false;
                  });
                },
              ),
              title: Text(
                "Step ${index + 1}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  steps[index],
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
