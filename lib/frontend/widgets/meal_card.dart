/*


class MealCard extends StatelessWidget {
  final String title;
  final double calories;
  final double protein;
  final double fats;
  final double carbs;
  final String imageUrl;

  const MealCard({
    super.key,
    required this.title,
    required this.calories,
    required this.protein,
    required this.fats,
    required this.carbs,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: imageUrl.startsWith('http')
              ? NetworkImage(imageUrl)
              : AssetImage(imageUrl) as ImageProvider,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${calories.toInt()} kcal • Protein: ${protein.toInt()}g • Fats: ${fats.toInt()}g • Carbs: ${carbs.toInt()}g',
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () async {
          },
        ),
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MealCard extends StatelessWidget {
  final String title;
  final double calories;
  final double protein;
  final double fats;
  final double carbs;
  final String imageUrl;
  final VoidCallback onDelete; // أضف هذا السطر

  const MealCard({
    super.key,
    required this.title,
    required this.calories,
    required this.protein,
    required this.fats,
    required this.carbs,
    required this.imageUrl,
    required this.onDelete, // أضف هذا السطر
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: imageUrl.startsWith('http')
              ? NetworkImage(imageUrl)
              : AssetImage(imageUrl) as ImageProvider,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${calories.toInt()} kcal • Protein: ${protein.toInt()}g • Fats: ${fats.toInt()}g • Carbs: ${carbs.toInt()}g',
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: onDelete, // استدعاء الدالة
        ),
      ),
    );
  }
}
