import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cookmate/frontend/widgets/Profile/profile_item_card.dart';
import 'package:flutter/material.dart';
import '../../../backend/models/profile_Recipe_view_model.dart';
import '../../../backend/services/profile_recipes_section_service.dart';


class ProfileRecipesSection extends StatefulWidget {
  final String userId;

  const ProfileRecipesSection({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfileRecipesSection> createState() => _ProfileRecipesSectionState();
}

class _ProfileRecipesSectionState extends State<ProfileRecipesSection> {
  final ScrollController _scrollController = ScrollController();
  final List<ProfileCollectionRecipesSectionModel> _recipes = [];
  DocumentSnapshot? _lastDoc;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      _fetchRecipes();
    }
  }

  Future<void> _fetchRecipes() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    final result = await ProfileRecipeSectionService.fetchUserRecipes(
      userId: widget.userId,
      lastDoc: _lastDoc,
    );

    setState(() {
      _recipes.addAll(result['recipes']);
      _lastDoc = result['lastDoc'];
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
      return const Center(child: Text('No recipes found'));
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
          },
        );
      },
    );
  }
}
