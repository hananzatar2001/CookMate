import 'package:flutter/material.dart';
import '../widgets/notification_bell.dart';

class DiscoveryRecipesPage extends StatefulWidget {
  const DiscoveryRecipesPage({super.key});

  @override
  State<DiscoveryRecipesPage> createState() => _DiscoveryRecipesPageState();
}

class _DiscoveryRecipesPageState extends State<DiscoveryRecipesPage> {
  final TextEditingController _searchController = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();

  OverlayEntry? _overlayEntry;

  final List<String> _allRecipes = [
    'Pomegranate',
    'Rice',
    'Ravioli',
    'Rolls',
    'Roti',
    'Roast',
  ];
  List<String> _filteredRecipes = [];

  int unreadCount = 5;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredRecipes =
          _allRecipes
              .where((recipe) => recipe.toLowerCase().contains(query))
              .toList();
    });
    _overlayEntry?.markNeedsBuild();
  }

  void _showOverlay() {
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
      builder:
          (context) => Positioned(
            width: size.width - 32,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: const Offset(16, 60),
              child: Material(
                elevation: 4.0,
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children:
                      _filteredRecipes.map((recipe) {
                        return ListTile(
                          title: Text(recipe),
                          onTap: () {
                            _searchController.text = recipe;
                            _removeOverlay();
                            FocusScope.of(context).unfocus();
                          },
                        );
                      }).toList(),
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

  void _viewRecipeDetails(String recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailsPage(recipe: recipe),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Discovery Recipes'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: NotificationBell(unreadCount: unreadCount),
          ),
        ],
      ),
      body: Column(
        children: [
          CompositedTransformTarget(
            link: _layerLink,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'Search for a recipe',
                  prefixIcon: const Icon(Icons.menu),
                  suffixIcon: const Icon(Icons.search),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: List.generate(
                  _filteredRecipes.isEmpty
                      ? _allRecipes.length
                      : _filteredRecipes.length,
                  (index) {
                    String recipe =
                        _filteredRecipes.isEmpty
                            ? _allRecipes[index]
                            : _filteredRecipes[index];
                    return GestureDetector(
                      onTap: () => _viewRecipeDetails(recipe),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(recipe, style: TextStyle(fontSize: 18)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RecipeDetailsPage extends StatelessWidget {
  final String recipe;

  const RecipeDetailsPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recipe Details for $recipe',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Ingredients:'),
            Text('• Ingredient 1'),
            Text('• Ingredient 2'),
            Text('• Ingredient 3'),
            SizedBox(height: 16),
            Text('Instructions:'),
            Text('1. Step 1'),
            Text('2. Step 2'),
            Text('3. Step 3'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Schedule this Recipe'),
            ),
          ],
        ),
      ),
    );
  }
}
