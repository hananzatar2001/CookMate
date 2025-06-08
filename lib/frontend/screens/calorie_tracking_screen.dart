import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../backend/services/CalorieLogService.dart';
import '../widgets/notification_bell.dart';
import '../widgets/nutrient_bar.dart';
import '../widgets/meal_card.dart';
import '../../frontend/widgets/NavigationBar.dart';
import '../../frontend/widgets/RecipeTypeSelector.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalorieTrackingScreen extends StatefulWidget {
  const CalorieTrackingScreen({super.key});

  @override
  State<CalorieTrackingScreen> createState() => _CalorieTrackingScreenState();
}

class _CalorieTrackingScreenState extends State<CalorieTrackingScreen> {
  final _logService = CalorieLogService();
  String? user_id;

  double totalCaloriesTaken = 0;
  int selectedRecipeIndex = 0;
  bool isLoading = true;
  double userCaloriesGoal = 2200;
  double userProteinGoal = 90;
  double userFatsGoal = 70;
  double userCarbsGoal = 110;
  double totalProteinTaken = 0;
  double totalFatsTaken = 0;
  double totalCarbsTaken = 0;

  List<Map<String, dynamic>> recipesForType = [];

  Future<void> loadUserCaloriesGoal()
  async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('UserCaloriesNeeded')
          .doc(user_id)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          userCaloriesGoal = (data['calories'] ?? 0).toDouble();
          userProteinGoal = (data['protein'] ?? 0).toDouble();
          userFatsGoal = (data['fats'] ?? 0).toDouble();
          userCarbsGoal = (data['carbs'] ?? 0).toDouble();
        });
      }
    } catch (e) {
      print('Error loading user calorie goals: $e');
    }
  }


  @override
  void initState() {
    super.initState();
    loadUserIdAndData();
  }

  Future<void> loadUserIdAndData() async {
    print('Loading user ID from SharedPreferences...');
    final prefs = await SharedPreferences.getInstance();
    final storedUserId = prefs.getString('userId');

    if (storedUserId != null) {
      setState(() {
        user_id = storedUserId;
      });
      print('User ID loaded: $user_id');

      await loadUserCaloriesGoal();
      await _logService.saveDailyNutritionSummary(user_id!, DateTime.now());
      await loadCaloriesFromLogs();

      final defaultType = ['Breakfast', 'Lunch', 'Dinner', 'Snack'][selectedRecipeIndex];
      print('Loading recipes for default type: $defaultType');
      await loadRecipesByType(defaultType);
    } else {
      setState(() {
        user_id = null;
      });
      print('No user ID found in SharedPreferences');
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> loadCaloriesFromLogs() async {
    final today = DateTime.now();
    final logDocId = '${user_id}_${today.toIso8601String().split('T')[0]}';

    print('📄 Trying to load CalorieLogs for doc ID: $logDocId');

    try {
      final doc = await FirebaseFirestore.instance
          .collection('CalorieLogs')
          .doc(logDocId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        print('📊 Calorie log data: $data');
        setState(() {
          totalCaloriesTaken = (data['Calories taken'] ?? 0).toDouble();
          totalProteinTaken = (data['protein taken'] ?? 0).toDouble();
          totalFatsTaken = (data['fats taken'] ?? 0).toDouble();
          totalCarbsTaken = (data['carbs taken'] ?? 0).toDouble();
        });
      } else {
        print('No log found for today.');
      }
    } catch (e) {
      print('Error loading CalorieLogs: $e');
    }
  }

  Color getProgressColor(double percent) {
    if (percent < 0.5) return Colors.green;
    if (percent < 0.8) return Colors.orange;
    return Colors.red;
  }

/*
  Future<void> loadRecipesByType(String type) async {
    if (user_id == null) return;
    final today = DateTime.now();

    final recipeLogs = await _logService.getRecipesForDateAndType(user_id!, today, type);
    final mealPlanLogs = await _logService.getLogsFromMealPlans(user_id!, today, type);

    final combined = [
      ...recipeLogs.map((e) { e['source']='Recipes'; return e; }),
      ...mealPlanLogs
    ];

    setState(() => recipesForType = combined);
    await _logService.saveDailyNutritionSummary(user_id!, today);
    await loadCaloriesFromLogs();
  }
*/
  Future<void> loadRecipesByType(String type) async {
    if (user_id == null) return;
    final today = DateTime.now();

    final recipeLogs = await _logService.getRecipesForDateAndType(user_id!, today, type);
    final mealPlanLogs = await _logService.getLogsFromMealPlans(user_id!, today, type);

    // دمج القائمتين
    List<Map<String, dynamic>> combined = [
      ...recipeLogs.map((e) {
        e['source'] = 'Recipes';
        return e;
      }),
      ...mealPlanLogs.map((e) {
        e['source'] = 'MealPlans';
        return e;
      }),
    ];

    final uniqueMap = <String, Map<String, dynamic>>{};
    for (var item in combined) {
      final id = item['recipe_id'] ?? item['id'] ?? item['docId'] ?? '';
      if (id.isNotEmpty && !uniqueMap.containsKey(id)) {
        uniqueMap[id] = item;
      }
    }

    setState(() => recipesForType = uniqueMap.values.toList());

    await _logService.saveDailyNutritionSummary(user_id!, today);
    await loadCaloriesFromLogs();
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final percent = userCaloriesGoal > 0
        ? (totalCaloriesTaken / userCaloriesGoal).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Material(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: AppBar(
              leading: const Icon(Icons.arrow_back_ios),
              title: const Text(
                'Calorie Tracking',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              actions: [NotificationBell(unreadCount: 5)],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 50),
          CircularPercentIndicator(
            radius: 100,
            lineWidth: 20,
            percent: percent,
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: getProgressColor(percent),
            backgroundColor: Colors.grey.shade200,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_fire_department,
                    color: Colors.orange, size: 32),
                Text(
                  '${totalCaloriesTaken.toInt()} Kcal',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  'of ${userCaloriesGoal.toInt()} kcal',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                NutrientBar(
                    label: 'Protein',
                    value: totalProteinTaken,
                    target: userProteinGoal,
                    color: Colors.green),
                NutrientBar(
                    label: 'Fats',
                    value: totalFatsTaken,
                    target: userFatsGoal,
                    color: Colors.red),
                NutrientBar(
                    label: 'Carbs',
                    value: totalCarbsTaken,
                    target: userCarbsGoal,
                    color: Colors.orange),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RecipeTypeSelector(
              selectedIndex: selectedRecipeIndex,
              onChanged: (index) async {
                setState(() {
                  selectedRecipeIndex = index;
                });
                final types = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
                await loadRecipesByType(types[index]);
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                final types = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
                await loadRecipesByType(types[selectedRecipeIndex]);
              },
            child: recipesForType.isEmpty
                ? const Center(child: Text("No meals found for selected type."))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: recipesForType.length,
              itemBuilder: (context, index) {
                final recipe = recipesForType[index];
                final recipeId = recipe['recipe_id'];

                return MealCard(
                  title: recipe['title'] ?? 'Unnamed Meal',
                  subtitle: Text(
                    recipe['source'] == 'MealPlans' ? 'From Meal Plans' : 'Added Manually',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  calories: (recipe['calories'] ?? 0).toDouble(),
                  protein: (recipe['Protein'] ?? 0).toDouble(),
                  fats: (recipe['Fats'] ?? 0).toDouble(),
                  carbs: (recipe['Carbs'] ?? 0).toDouble(),
                  imageUrl: recipe['image_url'] ?? 'assets/images/meal.png',

                  onDelete: () async {
                    final source = recipe['source'];
                    final id = recipe['recipe_id'] ?? recipe['id'] ?? recipe['docId'];

                    print('Attempting to delete from $source with id: $id');

                    if (id != null) {
                      try {
                        if (source == 'Recipes') {
                          await FirebaseFirestore.instance.collection('Recipes').doc(id).delete();
                          print('Done deleting from Recipes');
                        } else if (source == 'MealPlans') {
                          await FirebaseFirestore.instance.collection('MealPlans').doc(id).delete();
                          print('Done deleting from MealPlans');
                        } else {
                          print('Unknown source: $source');
                        }

                        setState(() {
                          recipesForType.removeAt(index);
                        });

                        await _logService.saveDailyNutritionSummary(user_id!, DateTime.now());
                        await loadCaloriesFromLogs();
                      } catch (e) {
                        print('❌ Error deleting $source entry: $e');
                      }
                    } else {
                      print('❌ id is null, cannot delete');
                    }
                  },
                );
              },
            ),
          ),
          )
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 7),
    );
  }
}
