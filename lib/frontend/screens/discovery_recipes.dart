import 'package:flutter/material.dart';
import '../../backend/services/recipe_discovery_service.dart';
import 'recipe_details.dart';
import 'package:cookmate/frontend/widgets/notification_bell.dart';
class DiscoveryRecipesPage extends StatefulWidget {
  const DiscoveryRecipesPage({super.key});

  @override
  State<DiscoveryRecipesPage> createState() => _DiscoveryRecipesPageState();
}

class _DiscoveryRecipesPageState extends State<DiscoveryRecipesPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final RecipeDiscoveryService _service = RecipeDiscoveryService();

  List<Map<String, dynamic>> _recipes = [];
  List<bool> pressedStates = [];
  bool isLoading = false;
  bool hasMore = true;
  int offset = 0;
  final int pageSize = 10;

  // افتراضياً userId ثابت هنا، استبدلها حسب التطبيق عندك
  final String userId = "some_user_id";

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

    try {
      final firestoreRecipes = await _service.fetchFromFirestore(query: query);
      final apiRecipes = await _service.fetchFromAPI(
        offset: offset,
        pageSize: pageSize,
        query: query,
      );

      setState(() {
        offset += pageSize;
        _recipes = [...firestoreRecipes, ...apiRecipes];
        pressedStates = List.generate(_recipes.length, (_) => false);
        hasMore = apiRecipes.length == pageSize;
      });
    } catch (e) {
      print('Error Fetching recipes: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          'Discovery Recipes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          NotificationBell(
            userId: userId,
            onTap: () {
              Navigator.pushNamed(context, '/notifications', arguments: userId);
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
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
                      builder: (context) => RecipeDetailsPage(recipe: recipe),
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
                              Future.delayed(
                                const Duration(milliseconds: 200),
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
                                },
                              );
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
                  query: _searchController.text.trim(),
                ),
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
