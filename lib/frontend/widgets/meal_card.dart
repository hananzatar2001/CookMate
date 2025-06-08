import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MealCard extends StatelessWidget {
  final String title;
  final Widget subtitle;
  final double calories;
  final double protein;
  final double fats;
  final double carbs;
  final String imageUrl;
  final VoidCallback onDelete;

  const MealCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.calories,
    required this.protein,
    required this.fats,
    required this.carbs,
    required this.imageUrl,
    required this.onDelete,
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: subtitle!,
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${calories.toInt()} kcal • Protein: ${protein.toInt()}g • Fats: ${fats.toInt()}g • Carbs: ${carbs.toInt()}g',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: onDelete,
        ),
      ),
    );
  }
}