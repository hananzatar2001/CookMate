import 'package:flutter/material.dart';
import 'package:cook_mate/backend/services/firestore_service.dart';
import 'package:cook_mate/backend/controllers/recipe_controller.dart';
import 'package:cook_mate/frontend/widgets/notification-bell.dart';
import 'package:cook_mate/frontend/screens/recipe_details.dart';

class DiscoveryRecipesPage extends StatefulWidget {
  const DiscoveryRecipesPage({super.key});

  @override
  State<DiscoveryRecipesPage> createState() => _DiscoveryRecipesPageState();
}

class _DiscoveryRecipesPageState extends State<DiscoveryRecipesPage> {
  final TextEditingController _searchController = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();
  final RecipeController _controller = RecipeController(FirestoreService());

  OverlayEntry? _overlayEntry;
  bool _isMenuTapped = false;
  List<Map<String, dynamic>> _recipes = [];

  bool isLoadingMore = false;
  bool hasMore = true;
  int unreadCount = 5;
  static const int maxRecipes = 50;

  // خريطة لتتبع حالة الضغط لكل وصفة (عنصر في القائمة)
  Map<int, bool> _isPressed = {};

  @override
  void initState() {
    super.initState();
    _loadInitialRecipes();
    _searchController.addListener(_onSearchChanged);
    _focusNode.addListener(() {
      if (_isMenuTapped) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    });
  }

  void _onSearchChanged() {
    if (_searchController.text.trim().isEmpty) {
      _loadInitialRecipes();
    }
  }

  void _toggleMenu() {
    setState(() {
      _isMenuTapped = !_isMenuTapped;
      if (_isMenuTapped) {
        _focusNode.requestFocus();
        _showOverlay();
      } else {
        _removeOverlay();
      }
    });
  }

  Future<void> _loadInitialRecipes() async {
    final initialRecipes = await _controller.getRecipesPaginated();
    setState(() {
      _recipes = initialRecipes.length > maxRecipes
          ? initialRecipes.sublist(0, maxRecipes)
          : initialRecipes;
      hasMore = initialRecipes.length > maxRecipes;
    });
  }

  void _searchRecipes() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    await _controller.fetchAndAddRecipes(query);
    final results = await _controller.getAllRecipes();

    setState(() {
      _recipes = results.length > maxRecipes ? results.sublist(0, maxRecipes) : results;
      hasMore = results.length > maxRecipes;
    });
  }

  Future<void> loadMoreRecipes() async {
    if (isLoadingMore || !hasMore || _recipes.length >= maxRecipes) return;

    setState(() {
      isLoadingMore = true;
    });

    final newRecipes = await _controller.getRecipesPaginated();

    setState(() {
      if (newRecipes.isEmpty) {
        hasMore = false;
      } else {
        final spaceLeft = maxRecipes - _recipes.length;
        final recipesToAdd = newRecipes.take(spaceLeft).toList();
        _recipes.addAll(recipesToAdd);
        hasMore = _recipes.length < maxRecipes && newRecipes.length == recipesToAdd.length;
      }
      isLoadingMore = false;
    });
  }

  void _showOverlay() {
    _removeOverlay();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;
    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width - 32,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(16, 60),
          child: Material(
            elevation: 4.0,
            child: ListTile(
              title: const Text('Press search to fetch recipes'),
              onTap: () {
                _removeOverlay();
                _focusNode.unfocus();
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _removeOverlay();
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
                  onTap: () {
                    print("Notifications bell tapped!");
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CompositedTransformTarget(
            link: _layerLink,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'Search for a recipe',
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: _toggleMenu,
                  ),
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
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: List.generate(_recipes.length, (index) {
                        final recipe = _recipes[index];
                        return GestureDetector(
                          onTap: () {
                            print("Tapped on recipe: ${recipe['title']}");
                          },
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
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                          child: Icon(Icons.image_not_supported));
                                    },
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
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                RecipeDetailsPage(recipe: recipe),
                                          ),
                                        );
                                      },
                                      onTapDown: (_) {
                                        setState(() {
                                          _isPressed[index] = true;
                                        });
                                      },
                                      onTapUp: (_) {
                                        setState(() {
                                          _isPressed[index] = false;
                                        });
                                      },
                                      onTapCancel: () {
                                        setState(() {
                                          _isPressed[index] = false;
                                        });
                                      },
                                      splashColor: Colors.white.withOpacity(0.3),
                                      highlightColor: Colors.transparent,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _isPressed[index] == true
                                              ? Colors.white.withOpacity(0.7)
                                              : Colors.transparent,
                                        ),
                                        child: Icon(
                                          Icons.add_circle_outline,
                                          size: 24,
                                          color: _isPressed[index] == true ? Colors.green : Colors.white,
                                        ),
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
                ),
                if (hasMore)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: ElevatedButton(
                      onPressed: isLoadingMore ? null : loadMoreRecipes,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF47551),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: isLoadingMore
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
          ),
        ],
      ),
    );
  }
}
