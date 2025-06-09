import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cookmate/frontend/widgets/Profile/profile_item_card.dart';
import 'package:flutter/material.dart';
import '../../../backend/models/profile_Recipe_view_model.dart';
import '../../../backend/services/profile_collection_section_service.dart';
import '../../screens/recipe_details.dart';

class ProfileCollectionSection extends StatefulWidget {
  final String userId;

  const ProfileCollectionSection({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfileCollectionSection> createState() => _ProfileCollectionSectionState();
}

class _ProfileCollectionSectionState extends State<ProfileCollectionSection> {
  final ScrollController _scrollController = ScrollController();
  final List< ProfileCollectionRecipesSectionModel > _recipes = [];
  final Set<String> _loadedRecipeIds = {};

  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastFavoriteDoc;
  DocumentSnapshot? _lastSavedDoc;

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    final result = await ProfileCollectionService.fetchRecipes(
      userId: widget.userId,
      lastFavoriteDoc: _lastFavoriteDoc,
      lastSavedDoc: _lastSavedDoc,
      loadedRecipeIds: _loadedRecipeIds,
    );

    setState(() {
      _recipes.addAll(result['recipes']);
      _lastFavoriteDoc = result['lastFavoriteDoc'];
      _lastSavedDoc = result['lastSavedDoc'];
      _hasMore = result['hasMore'];
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_recipes.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_recipes.isEmpty) {
      return const Center(child: Text('No saved or favorite recipes.'));
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(10),
      itemCount: _recipes.length + (_isLoading ? 1 : 0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 23,
        mainAxisSpacing: 11,
        childAspectRatio: 1.3,
      ),
      itemBuilder: (context, index) {
        if (index == _recipes.length) {
          return const Align(
            alignment: Alignment.centerRight,
            child: CircularProgressIndicator(),

          );
        }


        final recipe = _recipes[index];

        return ProfileItemCard(
          title: recipe.title,
          imageUrl: recipe.imageUrl,
          onTap: () {
            print('Tapped on recipe: ${recipe.title}');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipeDetailsPage(
                  recipe: {
                    'id': recipe.id,
                    'title': recipe.title,
                    'image_url': recipe.imageUrl,

                  },
                ),
              ),
            );

          },
        );
      },
    );
  }
}
