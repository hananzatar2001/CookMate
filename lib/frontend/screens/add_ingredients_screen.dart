import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cook_mate/backend/services/IngredientService.dart';
import '../../frontend/widgets/NavigationBar.dart';

class AddIngredientsScreen extends StatefulWidget {
  const AddIngredientsScreen({super.key});

  @override
  State<AddIngredientsScreen> createState() => _AddIngredientsScreenState();
}
class _AddIngredientsScreenState extends State<AddIngredientsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> suggestions = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final query = _searchController.text.trim();
      if (query.isNotEmpty) {
        final results = await IngredientService.fetchIngredients(query);
        setState(() {
          suggestions = List<Map<String, dynamic>>.from(results);
        });
      } else {
        setState(() {
          suggestions = [];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Ingredient'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search for the ingredient',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final item = suggestions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.restaurant_menu),
                    title: Text(item['name'] ?? 'Unknown'),
                    trailing: const Icon(Icons.add_circle_outline),
                    onTap: () {
                      Navigator.pop(context, item);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 8),
    );
  }
}
