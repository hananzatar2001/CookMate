import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../services/database_service.dart';
import '../models/models.dart';
import '../widgets/app_bar.dart';
import '../widgets/table_calendar.dart';
import '../widgets/meal_type_selector.dart';
import '../widgets/recipe_card.dart';
import '../widgets/empty_state_widget.dart';

class MealPlanningScreen extends StatefulWidget {
  const MealPlanningScreen({super.key});

  @override
  State<MealPlanningScreen> createState() => _MealPlanningScreenState();
}

class _MealPlanningScreenState extends State<MealPlanningScreen> {
  DateTime _selectedDate = DateTime.now();
  final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');

  String _selectedMealType = 'Breakfast';

  final ScrollController _recipesScrollController = ScrollController();

  final AppDatabase _appDatabase = DatabaseService().database;

  @override
  void initState() {
    super.initState();
    _appDatabase.addListener(_updateUI);
  }

  @override
  void dispose() {
    _appDatabase.removeListener(_updateUI);
    _recipesScrollController.dispose();
    super.dispose();
  }

  void _updateUI() {
    if (mounted) {
      setState(() {});
    }
  }

  List<Recipe> get _filteredRecipes {
    final recipes = _appDatabase.getRecipesForMeal(
      _selectedDate,
      _selectedMealType,
    );

    if (recipes.isEmpty) {
      return _appDatabase.getByMealType(_selectedMealType);
    }

    return recipes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(
        title: 'cookmate',
        showBackButton: false,
        notificationCount: _appDatabase.unreadNotificationsCount,
        onNotificationPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notifications accessed'),
              duration: Duration(seconds: 1),
            ),
          );
        },
      ),
      body: Column(
        children: [
          _buildCalendarSection(),
          MealTypeSelector(
            selectedMealType: _selectedMealType,
            onMealTypeSelected: (mealType) {
              setState(() {
                _selectedMealType = mealType;
              });
            },
          ),
          _buildMealsList(),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Meal Planning',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 16),
          _buildMonthNavigator(),
          const SizedBox(height: 8),
          _buildCalendar(),
        ],
      ),
    );
  }

  Widget _buildMonthNavigator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.grey),
          onPressed: () {
            setState(() {
              _selectedDate = DateTime(
                _selectedDate.year,
                _selectedDate.month - 1,
                _selectedDate.day,
              );
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Navigated to: ${DateFormat('MMMM yyyy').format(_selectedDate)}',
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: Text(
            _monthYearFormat.format(_selectedDate),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
          onPressed: () {
            setState(() {
              _selectedDate = DateTime(
                _selectedDate.year,
                _selectedDate.month + 1,
                _selectedDate.day,
              );
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Navigated to: ${DateFormat('MMMM yyyy').format(_selectedDate)}',
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      focusedDay: _selectedDate,
      firstDay: DateTime(2025, 1, 1),
      lastDay: DateTime(2025, 12, 31),
      currentDay: DateTime.now(),
      selectedDayPredicate: (day) {
        return _isSameDay(_selectedDate, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDate = selectedDay;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Selected: ${DateFormat('MMM d').format(selectedDay)}',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      headerVisible: false,
      calendarFormat: CalendarFormat.month,
    );
  }

  Widget _buildMealsList() {
    return Expanded(
      child:
          _filteredRecipes.isEmpty
              ? EmptyStateWidget(
                icon: Icons.no_meals,
                message: 'No $_selectedMealType meals planned',
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
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RecipeCategoryHeader(title: _selectedMealType),
                  Expanded(
                    child: Scrollbar(
                      controller: _recipesScrollController,
                      thumbVisibility: true,
                      thickness: 6,
                      radius: const Radius.circular(10),
                      scrollbarOrientation: ScrollbarOrientation.right,
                      child: ScrollbarTheme(
                        data: ScrollbarThemeData(
                          thumbColor: MaterialStateProperty.all(
                            Colors.black.withOpacity(0.6),
                          ),
                        ),
                        child: ListView.builder(
                          controller: _recipesScrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: _filteredRecipes.length,
                          itemBuilder: (context, index) {
                            final recipe = _filteredRecipes[index];
                            final userFavorites = _appDatabase.userFavoriteIds;
                            final isFavorite = userFavorites.contains(
                              recipe.id,
                            );

                            final inMealPlan = _isRecipeInMealPlan(recipe.id);

                            return RecipeCard(
                              recipe: recipe,
                              onTap: () {
                                _toggleMealPlan(recipe.id);
                              },
                              onFavoriteToggle:
                                  () => _toggleFavorite(recipe.id),
                              isFavorite: isFavorite,
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

  bool _isRecipeInMealPlan(String recipeId) {
    final recipes = _appDatabase.getRecipesForDate(_selectedDate);
    return recipes.any((recipe) => recipe.id == recipeId);
  }

  Future<void> _toggleMealPlan(String recipeId) async {
    if (_isRecipeInMealPlan(recipeId)) {
      await _appDatabase.removeRecipeFromMealPlan(_selectedDate, recipeId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe removed from meal plan'),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      await _appDatabase.addRecipeToMealPlan(_selectedDate, recipeId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe added to meal plan'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _toggleFavorite(String id) {
    _appDatabase.toggleFavorite(id);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class RecipeCategoryHeader extends StatelessWidget {
  final String title;

  const RecipeCategoryHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}
