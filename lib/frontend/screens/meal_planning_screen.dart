import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../frontend/widgets/NavigationBar.dart';
import '../../frontend/widgets/notification_bell.dart';
import '../../frontend/widgets/RecipeTypeSelector.dart';
import '../../backend/services/RecipeService.dart';
import '../../backend/models/recipe_model.dart';
import '../../backend/services/favorite_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../backend/controllers/meal_planning_controller.dart';

class MealPlanningScreen extends StatefulWidget {
  @override
  _MealPlanningScreenState createState() => _MealPlanningScreenState();
}

class _MealPlanningScreenState extends State<MealPlanningScreen> {
  final RecipeService _recipeService = RecipeService();
  final FavoriteService _favoriteService = FavoriteService();

  final List<String> recipeTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
  List<bool> selectedTypes = [true, false, false, false];

  DateTime selectedDate = DateTime.now();
  List<Recipe> meals = [];
  String? user_id;

  Set<String> favoriteRecipeIds = {};

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUserId = prefs.getString('userId');
    if (storedUserId != null) {
      setState(() {
        user_id = storedUserId;
      });
      await fetchMeals();
    } else {
      setState(() {
        user_id = null;
      });
    }
  }

  Future<void> fetchFavorites() async {
    if (user_id == null) return;

    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final userRef = _firestore.collection('users').doc(user_id);

    final snapshot = await _firestore
        .collection('Favorites')
        .where('user_id', isEqualTo: userRef)
        .get();

    setState(() {
      favoriteRecipeIds = snapshot.docs.map((doc) {
        final data = doc.data();
        final recipeRef = data['recipe_id'] as DocumentReference;
        return recipeRef.id;
      }).toSet();
    });
  }
  Future<void> fetchMeals() async {
    if (user_id == null) return;

    final selectedType = recipeTypes[selectedTypes.indexWhere((e) => e)];
    final results = await MealPlanningController()
        .fetchAllMealsByDateAndType(selectedDate, selectedType, user_id!);

    await fetchFavorites();

    setState(() {
      meals = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: const Text("Meal Planning"),
        actions: [
          NotificationBell(unreadCount: 3),
        ],
      ),
      body: Column(
        children: [
          CalendarDatePicker(
            initialDate: selectedDate,
            firstDate: DateTime(2024),
            lastDate: DateTime(2026),
            onDateChanged: (date) {
              setState(() {
                selectedDate = date;
              });
              fetchMeals();
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: RecipeTypeSelector(
              recipeTypes: recipeTypes,
              selectedIndex: selectedTypes.indexWhere((e) => e),
              onChanged: (index) {
                setState(() {
                  for (int i = 0; i < selectedTypes.length; i++) {
                    selectedTypes[i] = i == index;
                  }
                });
                fetchMeals();
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: meals.isEmpty
                ? const Center(child: Text('No meals found.'))
                : ListView.builder(
              itemCount: meals.length,
              itemBuilder: (_, i) {
                final meal = meals[i];
                final isFavorite = favoriteRecipeIds.contains(meal.recipe_id);

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: meal.image_url != null && meal.image_url!.isNotEmpty
                        ? Image.network(meal.image_url!,
                        width: 40, height: 40, fit: BoxFit.cover)
                        : Container(
                      width: 40,
                      height: 40,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image),
                    ),
                    title: Text(meal.title),
                    subtitle: Text("${meal.calories} kcal"),
                    trailing: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : null,
                      ),
                      onPressed: () async {
                        if (user_id == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('User not logged in')),
                          );
                          return;
                        }

                        if (isFavorite) {
                          await _favoriteService.removeFavorite(user_id!, meal.recipe_id!);
                          setState(() {
                            favoriteRecipeIds.remove(meal.recipe_id);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Removed from favorites')),
                          );
                        } else {
                          await _favoriteService.addFavorite(
                            user_id: user_id!,
                            recipeId: meal.recipe_id!,
                          );
                          setState(() {
                            favoriteRecipeIds.add(meal.recipe_id!);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Added to favorites')),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }
}
