import 'package:cookmate/pages/ingredient_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../services/database_service.dart';
import '../models/models.dart';
import '../widgets/app_bar.dart';
import '../widgets/meal_type_selector.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/recipe_card.dart';
import '../widgets/nutrient_progress.dart';
import '../pages/calorie_tracking.dart';

class DailyNutritionScreen extends StatefulWidget {
  const DailyNutritionScreen({super.key});

  @override
  State<DailyNutritionScreen> createState() => _DailyNutritionScreenState();
}

class _DailyNutritionScreenState extends State<DailyNutritionScreen> {
  final AppDatabase _appDatabase = DatabaseService().database;
  String _selectedCategory = 'Breakfast';
  final ScrollController _recipesScrollController = ScrollController();

  final DateTime _today = DateTime.now();

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
    _recipesScrollController.dispose();
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
    _totalCalories = user?.dailyCalorieTarget ?? 2213;
    _totalProtein = user?.dailyProteinTarget ?? 90;
    _totalCarbs = user?.dailyCarbsTarget ?? 110;
    _totalFat = user?.dailyFatTarget ?? 70;
    _totalFiber = user?.dailyFiberTarget ?? 25;

    final today = DateTime(_today.year, _today.month, _today.day);
    final nutritionRecord = _appDatabase.getNutritionByDate(today);

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
        _createDefaultNutritionForToday(user.id);
      }
    }
  }

  Future<void> _createDefaultNutritionForToday(String userId) async {
    final today = DateTime(_today.year, _today.month, _today.day);

    await _appDatabase.updateNutrition(
      today,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CommonAppBar(
        title: 'cookmate',
        showBackButton: false,
        showMenuButton: true,
        notificationCount: _appDatabase.unreadNotificationsCount,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateDisplay(),
              const SizedBox(height: 16),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CalorieTrackingPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildRecipeSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateDisplay() {
    final now = DateTime.now();
    final dayName = DateFormat('EEEE').format(now).toLowerCase();
    final dayNumber = now.day;
    String monthString = DateFormat('MMMM').format(now).toUpperCase();
    final month = monthString[0] + monthString.substring(1).toLowerCase();
    final year = now.year;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dayName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: textColor,
          ),
        ),
        Text(
          '$dayNumber $month $year',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recipes',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        MealTypeSelector(
          selectedMealType: _selectedCategory,
          onMealTypeSelected: (category) {
            setState(() {
              _selectedCategory = category;
            });
          },
          plainMode: true,
        ),
        const SizedBox(height: 16),
        _buildRecipeShowcaseList(),
      ],
    );
  }

  Widget _buildRecipeShowcaseList() {
    final today = DateTime(_today.year, _today.month, _today.day);
    final recipes = _appDatabase.getRecipesForMeal(today, _selectedCategory);

    final recipesToShow =
        recipes.isEmpty
            ? _appDatabase.getByMealType(_selectedCategory)
            : recipes;

    if (recipesToShow.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.restaurant,
        message: 'No $_selectedCategory recipes available',
        buttonText: 'Browse Recipes',
        onButtonPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Browse Recipes feature coming soon!'),
              duration: Duration(seconds: 1),
            ),
          );
        },
      );
    }

    return SizedBox(
      height: 180,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView.builder(
          controller: _recipesScrollController,
          scrollDirection: Axis.horizontal,
          itemCount: recipesToShow.length,
          itemBuilder: (context, index) {
            final recipe = recipesToShow[index];

            final userFavorites = _appDatabase.userFavoriteIds;
            final isFavorite = userFavorites.contains(recipe.id);

            final isInMealPlan = _isRecipeInMealPlan(recipe.id);

            return RecipeCard(
              recipe: recipe,
              isFavorite: isFavorite,
              onTap: () {
                _handleRecipeTap(recipe, isInMealPlan);
              },

              onLongPress: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailScreen(recipe: recipe),
                  ),
                );
              },
              onFavoriteToggle: () {
                _appDatabase.toggleFavorite(recipe.id);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isFavorite
                          ? 'Removed ${recipe.name} from favorites'
                          : 'Added ${recipe.name} to favorites',
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              compactDesign: true,
            );
          },
        ),
      ),
    );
  }

  void _handleRecipeTap(Recipe recipe, bool isInMealPlan) {
    if (isInMealPlan) {
      final today = DateTime(_today.year, _today.month, _today.day);
      _appDatabase.removeRecipeFromMealPlan(today, recipe.id);
      _removeRecipeNutrition(recipe);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed ${recipe.name} from meal plan'),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      final today = DateTime(_today.year, _today.month, _today.day);
      _appDatabase.addRecipeToMealPlan(today, recipe.id);
      _addRecipeNutrition(recipe);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${recipe.name} to meal plan'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  bool _isRecipeInMealPlan(String recipeId) {
    final today = DateTime(_today.year, _today.month, _today.day);
    final recipes = _appDatabase.getRecipesForDate(today);
    return recipes.any((recipe) => recipe.id == recipeId);
  }

  void _addRecipeNutrition(Recipe recipe) {
    final date = DateTime(_today.year, _today.month, _today.day);

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
    final date = DateTime(_today.year, _today.month, _today.day);

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
