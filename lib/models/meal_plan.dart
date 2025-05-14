import 'package:cloud_firestore/cloud_firestore.dart';

class MealPlanRecord {
  final String date;
  final List<String> recipeIds;

  MealPlanRecord({required this.date, required this.recipeIds});

  factory MealPlanRecord.fromJson(Map<String, dynamic> json) {
    return MealPlanRecord(
      date: json['date'],
      recipeIds: List<String>.from(json['recipeIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {'date': date, 'recipeIds': recipeIds};
  }
}

class MealPlan {
  final String id;
  final String userId;
  final List<MealPlanRecord> records;

  MealPlan({required this.id, required this.userId, required this.records});

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      id: json['id'],
      userId: json['userId'],
      records:
          (json['records'] as List?)
              ?.map(
                (record) =>
                    MealPlanRecord.fromJson(record as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'records': records.map((record) => record.toJson()).toList(),
    };
  }

  MealPlanRecord? getRecordForDate(DateTime date) {
    final dateStr = _formatDate(date);
    return records.firstWhere(
      (record) => record.date == dateStr,
      orElse: () => MealPlanRecord(date: dateStr, recipeIds: []),
    );
  }

  MealPlan addRecipe(DateTime date, String recipeId) {
    final dateStr = _formatDate(date);
    final updatedRecords = List<MealPlanRecord>.from(records);

    final index = updatedRecords.indexWhere((record) => record.date == dateStr);

    if (index >= 0) {
      final record = updatedRecords[index];
      if (!record.recipeIds.contains(recipeId)) {
        final updatedRecipeIds = List<String>.from(record.recipeIds)
          ..add(recipeId);
        updatedRecords[index] = MealPlanRecord(
          date: dateStr,
          recipeIds: updatedRecipeIds,
        );
      }
    } else {
      updatedRecords.add(MealPlanRecord(date: dateStr, recipeIds: [recipeId]));
    }

    return MealPlan(id: id, userId: userId, records: updatedRecords);
  }

  MealPlan removeRecipe(DateTime date, String recipeId) {
    final dateStr = _formatDate(date);
    final updatedRecords = List<MealPlanRecord>.from(records);

    final index = updatedRecords.indexWhere((record) => record.date == dateStr);

    if (index >= 0) {
      final record = updatedRecords[index];
      final updatedRecipeIds =
          record.recipeIds.where((id) => id != recipeId).toList();

      if (updatedRecipeIds.isEmpty) {
        updatedRecords.removeAt(index);
      } else {
        updatedRecords[index] = MealPlanRecord(
          date: dateStr,
          recipeIds: updatedRecipeIds,
        );
      }
    }

    return MealPlan(id: id, userId: userId, records: updatedRecords);
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
