import 'package:flutter/material.dart';
import '../widgets/app_bar.dart';
import '../widgets/base/section_title.dart';
import '../widgets/ingredient_card.dart';
import '../widgets/nutrient_progress.dart';
import '../models/recipe/recipe.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe? recipe;

  const RecipeDetailScreen({Key? key, this.recipe}) : super(key: key);

  Recipe _getExampleRecipe() {
    return Recipe(
      id: '633942',
      name: 'Balsamic Roasted Vegetables',
      description:
          'A delicious mix of vegetables roasted with balsamic vinegar.',
      calories: 290,
      weight: '1 serving',
      imageUrl: 'https://img.spoonacular.com/recipes/633942-556x370.jpg',
      mealType: 'Side Dish',
      protein: 5,
      carbs: 45,
      fat: 14,
      fiber: 95,
      ingredients: [
        Ingredient(
          name: 'Golden beets',
          amount: 2.0,
          unit: '',
          imageUrl:
              'https://spoonacular.com/cdn/ingredients_100x100/beets-golden.jpg',
        ),
        Ingredient(
          name: 'Red beets',
          amount: 2.0,
          unit: '',
          imageUrl: 'https://spoonacular.com/cdn/ingredients_100x100/beets.jpg',
        ),
        Ingredient(
          name: 'Bulb fennel',
          amount: 1.0,
          unit: '',
          imageUrl:
              'https://spoonacular.com/cdn/ingredients_100x100/fennel.png',
        ),
        Ingredient(
          name: 'Red onion',
          amount: 1.0,
          unit: 'small',
          imageUrl:
              'https://spoonacular.com/cdn/ingredients_100x100/red-onion.png',
        ),
      ],
      possibleIngredients: [
        'Canned Tomatoes',
        'Vegetable Oil',
        'Dried Basil',
        'Vegan Cheese',
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipeData = recipe ?? _getExampleRecipe();

    final List<Ingredient> recipeIngredients = recipeData.ingredients ?? [];

    final List<Map<String, dynamic>> ingredientDisplayData =
        recipeIngredients.isNotEmpty
            ? recipeIngredients.map<Map<String, dynamic>>((ingredient) {
              return {
                'name': ingredient.name,
                'imageUrl':
                    ingredient.imageUrl.isNotEmpty ? ingredient.imageUrl : null,
              };
            }).toList()
            : [
              {'name': 'Tomatoes', 'imageUrl': null},
              {'name': 'Olive Oil', 'imageUrl': null},
              {'name': 'Basil', 'imageUrl': null},
              {'name': 'Mozzarella', 'imageUrl': null},
            ];

    final List<Map<String, String>> substitutes =
        recipeData.possibleIngredients != null
            ? recipeData.possibleIngredients!.map<Map<String, String>>((name) {
              return {'name': name, 'imageUrl': ''};
            }).toList()
            : [
              {'name': 'Canned Tomatoes', 'imageUrl': ''},
              {'name': 'Vegetable Oil', 'imageUrl': ''},
              {'name': 'Dried Basil', 'imageUrl': ''},
              {'name': 'Vegan Cheese', 'imageUrl': ''},
            ];

    final int consumedCalories = recipeData.calories;
    final int totalCalories = 2000;

    final int consumedProtein = recipeData.protein;
    final int totalProtein = 90;
    final int consumedCarbs = recipeData.carbs;
    final int totalCarbs = 110;
    final int consumedFat = recipeData.fat;
    final int totalFat = 70;
    final int consumedFiber = recipeData.fiber;
    final int totalFiber = 25;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CommonAppBar(title: "Recipe Details", showEditIcon: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 220,
              width: double.infinity,
              color: Colors.black,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  recipeData.imageUrl.isNotEmpty
                      ? Image.network(
                        recipeData.imageUrl,
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image,
                            color: Colors.white,
                            size: 80,
                          );
                        },
                      )
                      : const Icon(Icons.image, color: Colors.white, size: 80),
                  Positioned(
                    right: 16,
                    top: 16,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                recipeData.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                recipeData.description,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SectionTitle(title: "Ingredients"),
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: 120,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                scrollDirection: Axis.horizontal,
                itemCount: ingredientDisplayData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: IngredientCard(
                      name: ingredientDisplayData[index]['name']!,
                      imageUrl: ingredientDisplayData[index]['imageUrl'],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SectionTitle(title: "Possible ingredients"),
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 120,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                scrollDirection: Axis.horizontal,
                itemCount: substitutes.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: IngredientCard(
                      name: substitutes[index]['name']!,
                      imageUrl: substitutes[index]['imageUrl'],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SectionTitle(title: "Nutrition Information"),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: NutrientProgress(
                            nutrientType: 'Protein',
                            consumed: consumedProtein,
                            total: totalProtein,
                            progressColor: Colors.green.shade400,
                            compactMode: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: NutrientProgress(
                            nutrientType: 'Fats',
                            consumed: consumedFat,
                            total: totalFat,
                            progressColor: const Color(0xFFF47458),
                            compactMode: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: NutrientProgress(
                            nutrientType: 'Carbs',
                            consumed: consumedCarbs,
                            total: totalCarbs,
                            progressColor: Colors.amber,
                            compactMode: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: NutrientProgress(
                            nutrientType: 'Fiber',
                            consumed: consumedFiber,
                            total: totalFiber,
                            progressColor: Colors.purple.shade400,
                            compactMode: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
