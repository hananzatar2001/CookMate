import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../../backend/controllers/home_screen_controller.dart';
import '../widgets/notification_bell.dart';
import '../widgets/RecipeTypeSelector.dart';
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
       // actions: [NotificationBell(unreadCount: 5)],
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
              const SizedBox(height: 10),
              _buildGaugeCard(),
              const SizedBox(height: 10),
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

  Widget _buildGaugeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FCE6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: SizedBox(
              height: 150,
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    radiusFactor: 0.9,
                    minimum: 0,
                    maximum: controller.userCaloriesGoal,
                    showLabels: false,
                    showTicks: false,
                    startAngle: 180,
                    endAngle: 0,
                    axisLineStyle: AxisLineStyle(
                      thickness: 0.2,
                      color: Colors.orange.shade100,
                      thicknessUnit: GaugeSizeUnit.factor,
                    ),
                    pointers: <GaugePointer>[
                      RangePointer(
                        value: controller.caloriesTaken,
                        width: 0.2,
                        color: Colors.deepOrange,
                        cornerStyle: CornerStyle.bothCurve,
                        sizeUnit: GaugeSizeUnit.factor,
                      ),
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        angle: 90,
                        positionFactor: 0.1,
                        widget: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${controller.caloriesTaken.toInt()} Kcal',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            Text('of ${controller.userCaloriesGoal.toInt()} kcal',
                                style: const TextStyle(fontSize: 14, color: Colors.black54)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNutrientLine("Protein", controller.totalProteinTaken, controller.userProteinGoal, Colors.green),
                _buildNutrientLine("Carbs", controller.totalCarbsTaken, controller.userCarbsGoal, Colors.orange),
                _buildNutrientLine("Fat", controller.totalFatsTaken, controller.userFatsGoal, Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientLine(String label, double value, double target, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          LinearProgressIndicator(
            value: (value / target).clamp(0.0, 1.0),
            color: color,
            backgroundColor: Colors.grey.shade200,
            minHeight: 5,
          ),
          const SizedBox(height: 2),
          Text('${value.toInt()} / ${target.toInt()}g', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
