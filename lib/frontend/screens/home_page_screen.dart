import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../backend/controllers/home_screen_controller.dart';
import '../../frontend/screens/discovery_recipes.dart';
import '../../frontend/screens/notifications_screen.dart';
import '../../frontend/widgets/NavigationBar.dart';
import '../../frontend/widgets/RecipeTypeSelector.dart';
import '../../frontend/widgets/calorie_card_home.dart';
import '../../frontend/widgets/hamburger_menu.dart';
import '../../frontend/widgets/home_view_recipe_card.dart';
import '../../frontend/widgets/notification_bell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeScreenController controller = HomeScreenController();
  String? userId;

  @override
  void initState() {
    super.initState();
    initializeController();
  }

  Future<void> initializeController() async {
    final success = await controller.initializeWithContext(context);
    if (success) {
      setState(() {
        userId = controller.userId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayName = DateFormat('EEEE').format(now).toLowerCase();
    final dateText = DateFormat('d-MMMM-yyyy').format(now);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black, size: 32),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'cookmate',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 40,
          ),
        ),
        actions: [
          if (userId != null)
            NotificationBell(
              userId: userId!,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationScreen(userId: userId!),
                  ),
                );
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.black),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please log in to see notifications')),
                );
              },
            ),
        ],
        centerTitle: true,
      ),
      drawer: const CustomDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.refreshAll();
          setState(() {});
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Text(dayName, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              Text(dateText, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              CalorieCardHome(
                caloriesTaken: controller.caloriesTaken,
                userCaloriesGoal: controller.userCaloriesGoal,
                totalProteinTaken: controller.totalProteinTaken,
                totalCarbsTaken: controller.totalCarbsTaken,
                totalFatsTaken: controller.totalFatsTaken,
                userProteinGoal: controller.userProteinGoal,
                userCarbsGoal: controller.userCarbsGoal,
                userFatsGoal: controller.userFatsGoal,
              ),
              const SizedBox(height: 20),
              const Text('Recipes', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Center(
                child: RecipeTypeSelector(
                  selectedIndex: controller.selectedRecipeIndex,
                  onChanged: (index) async {
                    await controller.updateRecipeType(index);
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<bool>(
                valueListenable: controller.isLoading,
                builder: (context, isLoading, _) {
                  if (isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return SizedBox(
                    height: 200,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.recipes.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final recipe = controller.recipes[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DiscoveryRecipesPage(),
                              ),
                            );
                          },
                          child: SizedBox(
                            width: 160,
                            child: HomeViewRecipeCard(
                              recipeId: recipe['id'],
                              title: recipe['title'],
                              imageUrl: recipe['image'],
                              calories: recipe['calories'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}
