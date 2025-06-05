import 'package:flutter/material.dart';

class RecipeTypeSelector extends StatelessWidget {
  final List<String> recipeTypes;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const RecipeTypeSelector({
    super.key,
    this.recipeTypes = const ['Breakfast', 'Lunch', 'Dinner', 'Snack'],
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      borderRadius: BorderRadius.circular(20),
      isSelected: List.generate(
        recipeTypes.length,
            (index) => index == selectedIndex,
      ),
      onPressed: (index) => onChanged(index),
      children: recipeTypes.map((type) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(type),
        );
      }).toList(),
    );
  }
}
