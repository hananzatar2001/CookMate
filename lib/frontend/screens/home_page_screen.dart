import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../backend/controllers/home_screen_controller.dart';
import '../widgets/RecipeTypeSelector.dart';
import '../widgets/calorie_card_home.dart';
import '../widgets/home_view_recipe_card.dart';
import '../widgets/NavigationBar.dart';
import '../widgets/hamburger_menu.dart';
import 'discovery_recipes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeScreenController controller = HomeScreenController();

  @override
  void initState() {
    super.initState();
    controller.initialize().then((_) => setState(() {}));
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
              controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
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
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }




}
