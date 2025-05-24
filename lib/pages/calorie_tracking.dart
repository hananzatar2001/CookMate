import 'package:flutter/material.dart';
import '../constants.dart';
import '../services/database_service.dart';
import '../models/models.dart';
import '../widgets/app_bar.dart';
import '../widgets/meal_type_selector.dart';
import '../widgets/recipe_card.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/nutrient_progress.dart';

class CalorieTrackingPage extends StatefulWidget {
  const CalorieTrackingPage({super.key});

  @override
  State<CalorieTrackingPage> createState() => _CalorieTrackingPageState();
}

class _CalorieTrackingPageState extends State<CalorieTrackingPage> {
  final AppDatabase _appDatabase = DatabaseService().database;

  final DateTime _selectedDate = DateTime.now();

  String _selectedMealType = 'Breakfast';

  late int _consumedCalories;
  late int _totalCalories;
  late int _consumedProtein;
  late int _totalProtein;
  late int _consumedCarbs;
  late int _totalCarbs;
  late int _consumedFat;
  late int _totalFat;
  late int _consumedFiber;
  late int _totalFiber;

  @override
  void initState() {
    super.initState();
    _appDatabase.addListener(_updateUI);
    _initNutritionData();
  }

  @override
  void dispose() {
    _appDatabase.removeListener(_updateUI);
    super.dispose();
  }

  void _updateUI() {
    if (mounted) {
      setState(() {
        _initNutritionData();
      });
    }
  }

  void _initNutritionData() {
    final user = _appDatabase.currentUser;
    _totalCalories = user?.dailyCalorieTarget ?? 2000;
    _totalProtein = user?.dailyProteinTarget ?? 100;
    _totalCarbs = user?.dailyCarbsTarget ?? 250;
    _totalFat = user?.dailyFatTarget ?? 65;
    _totalFiber = user?.dailyFiberTarget ?? 25;

    final date = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    final nutritionRecord = _appDatabase.getNutritionByDate(date);

    if (nutritionRecord != null) {
      _consumedCalories = nutritionRecord.consumedCalories;
      _consumedProtein = nutritionRecord.consumedProtein;
      _consumedCarbs = nutritionRecord.consumedCarbs;
      _consumedFat = nutritionRecord.consumedFat;
      _consumedFiber = nutritionRecord.consumedFiber;

      if (nutritionRecord.targetCalories > 0) {
        _totalCalories = nutritionRecord.targetCalories;
      }
      if (nutritionRecord.targetProtein > 0) {
        _totalProtein = nutritionRecord.targetProtein;
      }
      if (nutritionRecord.targetCarbs > 0) {
        _totalCarbs = nutritionRecord.targetCarbs;
      }
      if (nutritionRecord.targetFat > 0) _totalFat = nutritionRecord.targetFat;
      if (nutritionRecord.targetFiber > 0)
        _totalFiber = nutritionRecord.targetFiber;
    } else {
      _consumedCalories = 0;
      _consumedProtein = 0;
      _consumedCarbs = 0;
      _consumedFat = 0;
      _consumedFiber = 0;

      if (user != null) {
        _createDefaultNutritionForDate(user.id);
      }
    }
  }

  Future<void> _createDefaultNutritionForDate(String userId) async {
    final date = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    await _appDatabase.updateNutrition(
      date,
      consumedCalories: 0,
      consumedProtein: 0,
      consumedCarbs: 0,
      consumedFat: 0,
      consumedFiber: 0,
      targetCalories: _totalCalories,
      targetProtein: _totalProtein,
      targetCarbs: _totalCarbs,
      targetFat: _totalFat,
      targetFiber: _totalFiber,
    );
  }

  List<Recipe> get _filteredRecipes {
    return _appDatabase.getRecipesForMeal(_selectedDate, _selectedMealType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CommonAppBar(
        title: 'Calorie Tracking',
        notificationCount: _appDatabase.unreadNotificationsCount,
      ),
      body: Column(
        children: [
          SizedBox(height: 24),
          NutrientCard(
            consumedCalories: _consumedCalories,
            totalCalories: _totalCalories,
            consumedProtein: _consumedProtein,
            totalProtein: _totalProtein,
            consumedCarbs: _consumedCarbs,
            totalCarbs: _totalCarbs,
            consumedFat: _consumedFat,
            totalFat: _totalFat,
            consumedFiber: _consumedFiber,
            totalFiber: _totalFiber,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Nutrition details tapped'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),

          MealTypeSelector(
            selectedMealType: _selectedMealType,
            onMealTypeSelected: (mealType) {
              setState(() {
                _selectedMealType = mealType;
              });
            },
          ),

          Expanded(
            child:
                _filteredRecipes.isEmpty
                    ? EmptyStateWidget(
                      icon: Icons.restaurant,
                      message: 'No $_selectedMealType recipes',
                      buttonText: 'Add Recipe',
                      onButtonPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Add Recipe feature coming soon!'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    )
                    : _buildRecipesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _filteredRecipes.length,
      itemBuilder: (context, index) {
        final recipe = _filteredRecipes[index];

        final userFavorites = _appDatabase.userFavoriteIds;
        final isFavorite = userFavorites.contains(recipe.id);

        final isInMealPlan = _isRecipeInMealPlan(recipe.id);

        return RecipeCard(
          recipe: recipe,
          isFavorite: isFavorite,

          onTap: () {
            if (isInMealPlan) {
              _appDatabase.removeRecipeFromMealPlan(_selectedDate, recipe.id);
              _removeRecipeNutrition(recipe);
            } else {
              _appDatabase.addRecipeToMealPlan(_selectedDate, recipe.id);
              _addRecipeNutrition(recipe);
            }
          },
          onFavoriteToggle: () => _toggleFavorite(recipe.id),
          showMacros: true,
        );
      },
    );
  }

  bool _isRecipeInMealPlan(String recipeId) {
    final recipes = _appDatabase.getRecipesForDate(_selectedDate);
    return recipes.any((recipe) => recipe.id == recipeId);
  }

  void _toggleFavorite(String id) {
    _appDatabase.toggleFavorite(id);
  }

  void _addRecipeNutrition(Recipe recipe) {
    final date = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    _consumedCalories += recipe.calories;
    _consumedProtein += recipe.protein;
    _consumedCarbs += recipe.carbs;
    _consumedFat += recipe.fat;
    _consumedFiber += recipe.fiber;

    _appDatabase.updateNutrition(
      date,
      consumedCalories: _consumedCalories,
      consumedProtein: _consumedProtein,
      consumedCarbs: _consumedCarbs,
      consumedFat: _consumedFat,
      consumedFiber: _consumedFiber,
    );

    setState(() {});
  }

  void _removeRecipeNutrition(Recipe recipe) {
    final date = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    _consumedCalories = (_consumedCalories - recipe.calories).clamp(
      0,
      _totalCalories,
    );
    _consumedProtein = (_consumedProtein - recipe.protein).clamp(
      0,
      _totalProtein,
    );
    _consumedCarbs = (_consumedCarbs - recipe.carbs).clamp(0, _totalCarbs);
    _consumedFat = (_consumedFat - recipe.fat).clamp(0, _totalFat);
    _consumedFiber = (_consumedFiber - recipe.fiber).clamp(0, _totalFiber);

    _appDatabase.updateNutrition(
      date,
      consumedCalories: _consumedCalories,
      consumedProtein: _consumedProtein,
      consumedCarbs: _consumedCarbs,
      consumedFat: _consumedFat,
      consumedFiber: _consumedFiber,
    );

    setState(() {});
  }
}
