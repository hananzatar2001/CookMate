import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cook_mate/frontend/widgets/notification-bell.dart';
import 'recipe_details.dart';

class DiscoveryRecipesPage extends StatefulWidget {
  const DiscoveryRecipesPage({super.key});

  @override
  State<DiscoveryRecipesPage> createState() => _DiscoveryRecipesPageState();
}

class _DiscoveryRecipesPageState extends State<DiscoveryRecipesPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final String apiKey = '5cbc633fbbd840a29f5a29225a1ad55f';

  List<Map<String, dynamic>> _recipes = [];
  List<bool> pressedStates = [];
  bool isLoading = false;
  bool hasMore = true;
  int offset = 0;
  int unreadCount = 5;
  final int pageSize = 10;

  @override
  void initState() {
    super.initState();
    fetchRecipes(); // Initial fetch
  }

  Future<void> fetchRecipes({String query = ''}) async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    final url = Uri.https('api.spoonacular.com', '/recipes/complexSearch', {
      'apiKey': apiKey,
      'query': query,
      'number': '$pageSize',
      'offset': '$offset',
    });

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];

      setState(() {
        offset += pageSize;
        _recipes.addAll(results.map((e) => {
          'id': e['id'],
          'title': e['title'],
          'image_url': e['image'],
        }));
        pressedStates.addAll(List.generate(results.length, (_) => false));
        hasMore = results.length == pageSize;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      print('Failed to fetch recipes: ${response.statusCode}');
    }
  }

  void _searchRecipes() {
    setState(() {
      _recipes.clear();
      pressedStates.clear();
      offset = 0;
      hasMore = true;
    });
    fetchRecipes(query: _searchController.text.trim());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 48),
              const Text(
                'Discovery Recipes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: NotificationBell(
                  unreadCount: unreadCount,
                  onTap: () => print("Notifications bell tapped!"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Search for a recipe',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchRecipes,
                ),
                filled: true,
                fillColor: const Color(0xFFF1E9F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Find My Next Favorite Meal',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: List.generate(_recipes.length, (index) {
                final recipe = _recipes[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RecipeDetailsPage(recipe: recipe),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            recipe['image_url'] ?? '',
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                            const Center(child: Icon(Icons.broken_image)),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.black.withOpacity(0.3),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 8,
                          right: 8,
                          child: Text(
                            recipe['title'] ?? 'No Title',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                pressedStates[index] = true;
                              });
                              Future.delayed(const Duration(milliseconds: 200),
                                      () {
                                    setState(() {
                                      pressedStates[index] = false;
                                    });
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            RecipeDetailsPage(recipe: recipe),
                                      ),
                                    );
                                  });
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: pressedStates[index]
                                    ? Colors.grey.shade400
                                    : Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 20,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          if (hasMore)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () => fetchRecipes(
                    query: _searchController.text.trim()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF47551),
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Load More'),
              ),
            ),
        ],
      ),
    );
  }
}
