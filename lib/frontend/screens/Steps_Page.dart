import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../frontend/widgets/notification_bell.dart';

class StepsPage extends StatefulWidget {
  final int recipeId;

  const StepsPage({super.key, required this.recipeId});

  @override
  State<StepsPage> createState() => _StepsPageState();
}

class _StepsPageState extends State<StepsPage> {
  static const String apiKey = 'eaf8e536e30445a4b4862cdcaa7dbb0f';

  bool isLoading = true;
  List<String> steps = [];
  List<bool> checkedSteps = [];
  String error = '';

  int unreadCount = 0; // عداد الإشعارات الغير مقروءة

  @override
  void initState() {
    super.initState();
    fetchSteps();
    // هنا ممكن تجلب عدد الإشعارات الحقيقية لو عندك
  }

  Future<void> fetchSteps() async {
    try {
      final url = Uri.parse(
          'https://api.spoonacular.com/recipes/${widget.recipeId}/information?apiKey=$apiKey&includeNutrition=false');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final stepsData = (data['analyzedInstructions'] != null &&
            data['analyzedInstructions'].isNotEmpty)
            ? data['analyzedInstructions'][0]['steps']
            : [];

        setState(() {
          steps = stepsData.map<String>((s) => s['step'].toString()).toList();
          checkedSteps = List<bool>.filled(steps.length, false);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load steps';
          isLoading = false;
        });
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
        title: const Text('Recipe Steps'),
        actions: [
         // NotificationBell(unreadCount: unreadCount),
        ],
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
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 3,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Checkbox(
                value: checkedSteps[index],
                onChanged: (bool? value) {
                  setState(() {
                    checkedSteps[index] = value ?? false;
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
