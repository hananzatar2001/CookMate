import 'package:cookmate/frontend/screens/home_page_screen.dart';
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
import '../../frontend/screens/home_page_screen.dart';

class CalorieTrackingScreen extends StatefulWidget {
  const CalorieTrackingScreen({super.key});

  @override
  State<CalorieTrackingScreen> createState() => _CalorieTrackingScreenState();
}

class _CalorieTrackingScreenState extends State<CalorieTrackingScreen> {
  final CalorieLogService _logService = CalorieLogService();
  String? userId;

  double userCaloriesGoal = 0;
  double userProteinGoal = 0;
  double userFatsGoal = 0;
  double userCarbsGoal = 0;

  double totalCaloriesTaken = 0;
  double totalProteinTaken = 0;
  double totalFatsTaken = 0;
  double totalCarbsTaken = 0;

  bool isLoading = true;

  int selectedRecipeIndex = 0;
  final List<String> mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  List<Map<String, dynamic>> recipesForType = [];

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final storedUserId = prefs.getString('userId');

    if (storedUserId != null) {
      userId = storedUserId;
      await loadUserGoals();
      await _logService.saveDailyNutritionSummary(userId!, DateTime.now());
      await loadCaloriesFromLogs();
      await loadRecipesByType(mealTypes[selectedRecipeIndex]);
      await _logService.printDailyNutritionSummary(userId!, DateTime.now(), mealTypes[selectedRecipeIndex]);

      setState(() {});
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> loadUserGoals() async {
    if (userId == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('UserCaloriesNeeded')
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          userCaloriesGoal = (data['calories'] ?? 0).toDouble();
          userProteinGoal = (data['Protein'] ?? 0).toDouble();
          userFatsGoal = (data['Fats'] ?? 0).toDouble();
          userCarbsGoal = (data['Carbs'] ?? 0).toDouble();
        });
      }
    } catch (e) {
      print('❌ Error loading user goals: $e');
    }
  }

  Future<void> loadCaloriesFromLogs() async {
    if (userId == null) return;

    try {
      final today = DateTime.now();
      final docId = '${userId}_${today.toIso8601String().split('T')[0]}';

      final doc = await FirebaseFirestore.instance
          .collection('CalorieLogs')
          .doc(docId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          totalCaloriesTaken = (data['Calories taken'] ?? 0).toDouble();
          totalProteinTaken = (data['protein taken'] ?? 0).toDouble();
          totalFatsTaken = (data['Fats taken'] ?? 0).toDouble();
          totalCarbsTaken = (data['Carbs taken'] ?? 0).toDouble();
        });
      } else {
        setState(() {
          totalCaloriesTaken = 0;
          totalProteinTaken = 0;
          totalFatsTaken = 0;
          totalCarbsTaken = 0;
        });
      }
    } catch (e) {
      print('❌ Error loading daily log: $e');
    }
  }

  Future<void> loadRecipesByType(String mealType) async {
    if (userId == null) return;

    setState(() {
      isLoading = true;
    });

    final recipes = await _logService.getLogsFromMealPlans(userId!, DateTime.now(), mealType);

    setState(() {
      recipesForType = recipes;
      isLoading = false;
    });
  }

  Color getProgressColor(double percent) {
    if (percent < 0.5) return Colors.green;
    if (percent < 0.75) return Colors.orange;
    return Colors.red;
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
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
              ),
              title: const Text(
                'Calorie Tracking',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
              titleTextStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
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
                  isLoading = true;
                });
                await loadRecipesByType(mealTypes[index]);
                setState(() {
                  isLoading = false;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await loadRecipesByType(mealTypes[selectedRecipeIndex]);
              },
              child: recipesForType.isEmpty
                  ? const Center(child: Text("No meals found for selected type."))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: recipesForType.length,
                itemBuilder: (context, index) {
                  final recipe = recipesForType[index];
                  final id = recipe['id'];

                  return MealCard(
                    title: recipe['title'] ?? 'Unnamed Meal',
                    subtitle: Text(
                      recipe['source'] == 'MealPlans'
                          ? 'From Meal Plans'
                          : 'Added Manually',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    calories: (recipe['calories'] ?? 0),
                    protein: (recipe['Protein'] ?? 0),
                    fats: (recipe['Fats'] ?? 0),
                    carbs: (recipe['Carbs'] ?? 0),
                    imageUrl: recipe['image_url'] ?? 'assets/images/meal.png',

                  /*onDelete: () async {
                    try {
                      await _logService.deleteMealPlan(id);

                      // بعد الحذف، أعد تحميل الوصفات حسب نوع الوجبة
                      await loadRecipesByType(mealTypes[selectedRecipeIndex]);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Meal deleted successfully')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to delete meal')),
                      );
                    }
                  }*/
                      onDelete: () async {
                        try {
                          // حذف الوجبة من قاعدة البيانات
                          await _logService.deleteMealPlan(id);

                          // إعادة تحميل الوصفات لنوع الوجبة الحالي
                          await loadRecipesByType(mealTypes[selectedRecipeIndex]);

                          // إعادة حساب وحفظ بيانات التغذية اليومية بعد الحذف
                          if (userId != null) {
                            await _logService.saveDailyNutritionSummary(userId!, DateTime.now());

                            // إعادة تحميل بيانات الكالوريز والماكروز المعروضة في الشاشة
                            await loadCaloriesFromLogs();
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Meal deleted successfully')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to delete meal')),
                          );
                        }
                      }



                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: -1),
    );
  }
}
