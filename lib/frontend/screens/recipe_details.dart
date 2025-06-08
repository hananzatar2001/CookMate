import 'package:flutter/material.dart';
import 'package:cookmate/frontend/widgets/custom_save_button.dart';
import 'package:cookmate/frontend/widgets/NavigationBar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'Ingredients_Page.dart';
import 'Steps_Page.dart';
import '../../backend/controllers/recipe_controller.dart';

class RecipeDetailsPage extends StatefulWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailsPage({super.key, required this.recipe});

  @override
  State<RecipeDetailsPage> createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> {
  late RecipeDetailsController controller;
  int selectedTabIndex = 0;
  bool hasTappedVideoTab = false;

  @override
  void initState() {
    super.initState();
    controller = RecipeDetailsController(recipe: widget.recipe);
    controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    controller.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final imageUrl = recipe['image_url'] ?? recipe['image'] ?? '';

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        actions: [
          CustomSaveButton(
            isSaved: controller.isSaved,
            onPressed: () async {
              final result = await controller.saveOrDeleteRecipe();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Recipe $result')),
              );
            },
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : buildContent(context, imageUrl),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: selectedTabIndex),
    );
  }

  Widget buildContent(BuildContext context, String imageUrl) {
    return Column(
      children: [
        Image.network(
          imageUrl,
          height: 180,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
          const Center(child: Icon(Icons.broken_image)),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            widget.recipe['title'] ?? "Recipe Name",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildTab(0, "Video", Colors.amber[200]!),
            _buildTab(1, "Ingredients", Colors.green[100]!),
            _buildTab(2, "Steps", Colors.purple[100]!),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (selectedTabIndex == 0 && hasTappedVideoTab)
                  controller.youtubeVideoId != null
                      ? ElevatedButton(
                    onPressed: () => _launchVideo(
                        'https://www.youtube.com/watch?v=${controller.youtubeVideoId}'),
                    child: const Text("Watch Video"),
                  )
                      : const Text("No related video found"),
                const SizedBox(height: 24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Nutrition Information",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 3,
                  children: [
                    _buildNutritionBar(
                        "Protein", controller.protein.toInt(), 100, Colors.orangeAccent),
                    _buildNutritionBar(
                        "Fat", controller.fat.toInt(), 100, Colors.redAccent),
                    _buildNutritionBar(
                        "Carbs", controller.carbs.toInt(), 100, Colors.blueAccent),
                    _buildNutritionBar(
                        "Fiber", controller.fiber.toInt(), 100, Colors.greenAccent),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    showMealPlanBottomSheet(context);
                  },
                  child: const Text("Add to Meal Plan"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF47551),
                    foregroundColor: Colors.white,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionBar(String label, int value, int maxValue, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: $value g"),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              width: (MediaQuery.of(context).size.width - 72) / 2,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            Container(
              width: (value / maxValue) * (MediaQuery.of(context).size.width - 72) / 2,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildTab(int index, String label, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15),

        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: () {
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => IngredientsPage(recipeId: widget.recipe['id'])),
              ).then((_) {
                setState(() {
                  selectedTabIndex = 0;
                  hasTappedVideoTab = false;
                });
              });
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => StepsPage(recipeId: widget.recipe['id'])),
              ).then((_) {
                setState(() {
                  selectedTabIndex = 0;
                  hasTappedVideoTab = false;
                });
              });
            } else {
              setState(() {
                selectedTabIndex = index;
                hasTappedVideoTab = true;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight:
                  selectedTabIndex == index ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _launchVideo(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the video')),
      );
    }
  }

  void showMealPlanBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 8),
                  Text("Date: ${DateFormat.yMMMd().format(controller.selectedDate)}"),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: controller.selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (pickedDate != null) {
                        setState(() => controller.selectedDate = pickedDate);
                      }
                    },
                    child: const Text("Change"),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.access_time),
                  const SizedBox(width: 8),
                  Text("Time: ${controller.selectedTime.format(context)}"),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: controller.selectedTime,
                      );
                      if (pickedTime != null) {
                        setState(() => controller.selectedTime = pickedTime);
                      }
                    },
                    child: const Text("Change"),
                  ),
                ],
              ),
              DropdownButtonFormField<String>(
                value: controller.selectedMeal,
                items: const [
                  DropdownMenuItem(value: "Breakfast", child: Text("Breakfast")),
                  DropdownMenuItem(value: "Lunch", child: Text("Lunch")),
                  DropdownMenuItem(value: "Dinner", child: Text("Dinner")),
                  DropdownMenuItem(value: "Snack", child: Text("Snack")),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => controller.selectedMeal = val);
                  }
                },
                decoration: const InputDecoration(
                  labelText: "Meal Type",
                  prefixIcon: Icon(Icons.restaurant_menu),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Save to Meal Plan"),
                onPressed: () async {
                  final result = await controller.addToMealPlan();
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Meal Plan: $result")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF47551),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
