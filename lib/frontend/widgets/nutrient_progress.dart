import 'package:cookmate/frontend/widgets/calorie_progress_indicator.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';

class NutrientProgress extends StatelessWidget {
  final String nutrientType;
  final int consumed;
  final int total;
  final Color progressColor;
  final bool compactMode;

  const NutrientProgress({
    super.key,
    required this.nutrientType,
    required this.consumed,
    required this.total,
    required this.progressColor,
    this.compactMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? consumed / total : 0.0;

    if (compactMode) {
      return _buildCompactProgress(progress);
    } else {
      return _buildFullProgress(progress);
    }
  }

  Widget _buildFullProgress(double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nutrientType,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),

        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: Colors.grey.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
        const SizedBox(height: 8),

        Text(
          '$consumed/${total}g',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactProgress(double progress) {
    return Column(
      children: [
        Text(
          nutrientType,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$consumed/${total}g',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class NutrientCard extends StatelessWidget {
  final int consumedCalories;
  final int totalCalories;
  final int consumedProtein;
  final int totalProtein;
  final int consumedCarbs;
  final int totalCarbs;
  final int consumedFat;
  final int totalFat;
  final int consumedFiber;
  final int totalFiber;
  final VoidCallback? onTap;

  const NutrientCard({
    super.key,
    required this.consumedCalories,
    required this.totalCalories,
    required this.consumedProtein,
    required this.totalProtein,
    required this.consumedCarbs,
    required this.totalCarbs,
    required this.consumedFat,
    required this.totalFat,
    required this.consumedFiber,
    required this.totalFiber,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Center(
                child: CalorieProgressIndicator(
                  consumedCalories: consumedCalories,
                  totalCalories: totalCalories,
                ),
              ),
            ),

            const SizedBox(height: 20),

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
    );
  }
}
