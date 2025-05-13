import 'package:cloud_firestore/cloud_firestore.dart';

class NutritionRecord {
  final String date;
  final int consumedCalories;
  final int consumedProtein;
  final int consumedCarbs;
  final int consumedFat;
  final int targetCalories;
  final int targetProtein;
  final int targetCarbs;
  final int targetFat;

  NutritionRecord({
    required this.date,
    required this.consumedCalories,
    required this.consumedProtein,
    required this.consumedCarbs,
    required this.consumedFat,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
  });

  factory NutritionRecord.fromJson(Map<String, dynamic> json) {
    return NutritionRecord(
      date: json['date'],
      consumedCalories: json['consumedCalories'] ?? 0,
      consumedProtein: json['consumedProtein'] ?? 0,
      consumedCarbs: json['consumedCarbs'] ?? 0,
      consumedFat: json['consumedFat'] ?? 0,
      targetCalories: json['targetCalories'] ?? 0,
      targetProtein: json['targetProtein'] ?? 0,
      targetCarbs: json['targetCarbs'] ?? 0,
      targetFat: json['targetFat'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'consumedCalories': consumedCalories,
      'consumedProtein': consumedProtein,
      'consumedCarbs': consumedCarbs,
      'consumedFat': consumedFat,
      'targetCalories': targetCalories,
      'targetProtein': targetProtein,
      'targetCarbs': targetCarbs,
      'targetFat': targetFat,
    };
  }

  NutritionRecord updateConsumed({
    int? calories,
    int? protein,
    int? carbs,
    int? fat,
  }) {
    return NutritionRecord(
      date: date,
      consumedCalories: calories ?? consumedCalories,
      consumedProtein: protein ?? consumedProtein,
      consumedCarbs: carbs ?? consumedCarbs,
      consumedFat: fat ?? consumedFat,
      targetCalories: targetCalories,
      targetProtein: targetProtein,
      targetCarbs: targetCarbs,
      targetFat: targetFat,
    );
  }

  NutritionRecord updateTargets({
    int? calories,
    int? protein,
    int? carbs,
    int? fat,
  }) {
    return NutritionRecord(
      date: date,
      consumedCalories: consumedCalories,
      consumedProtein: consumedProtein,
      consumedCarbs: consumedCarbs,
      consumedFat: consumedFat,
      targetCalories: calories ?? targetCalories,
      targetProtein: protein ?? targetProtein,
      targetCarbs: carbs ?? targetCarbs,
      targetFat: fat ?? targetFat,
    );
  }
}

class Nutrition {
  final String id;
  final String userId;
  final List<NutritionRecord> records;

  Nutrition({required this.id, required this.userId, required this.records});

  factory Nutrition.fromJson(Map<String, dynamic> json) {
    return Nutrition(
      id: json['id'],
      userId: json['userId'],
      records:
          (json['records'] as List?)
              ?.map(
                (record) =>
                    NutritionRecord.fromJson(record as Map<String, dynamic>),
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

  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  NutritionRecord? getRecordForDate(DateTime date) {
    final dateStr = formatDate(date);
    try {
      return records.firstWhere((record) => record.date == dateStr);
    } catch (e) {
      return null;
    }
  }

  Nutrition updateRecord(NutritionRecord newRecord) {
    final updatedRecords = List<NutritionRecord>.from(records);

    final index = updatedRecords.indexWhere(
      (record) => record.date == newRecord.date,
    );

    if (index >= 0) {
      updatedRecords[index] = newRecord;
    } else {
      updatedRecords.add(newRecord);
    }

    return Nutrition(id: id, userId: userId, records: updatedRecords);
  }

  Nutrition updateConsumedNutrients(
    DateTime date, {
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
    int? targetCalories,
    int? targetProtein,
    int? targetCarbs,
    int? targetFat,
  }) {
    final dateStr = formatDate(date);
    final existingRecord = getRecordForDate(date);

    final newRecord =
        existingRecord != null
            ? existingRecord.updateConsumed(
              calories: calories,
              protein: protein,
              carbs: carbs,
              fat: fat,
            )
            : NutritionRecord(
              date: dateStr,
              consumedCalories: calories,
              consumedProtein: protein,
              consumedCarbs: carbs,
              consumedFat: fat,
              targetCalories: targetCalories ?? 0,
              targetProtein: targetProtein ?? 0,
              targetCarbs: targetCarbs ?? 0,
              targetFat: targetFat ?? 0,
            );

    return updateRecord(newRecord);
  }

  Nutrition updateTargets(
    DateTime date, {
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
  }) {
    final dateStr = formatDate(date);
    final updatedRecords = <NutritionRecord>[];

    for (final record in records) {
      if (record.date.compareTo(dateStr) >= 0) {
        updatedRecords.add(
          record.updateTargets(
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
          ),
        );
      } else {
        updatedRecords.add(record);
      }
    }

    if (!updatedRecords.any((record) => record.date == dateStr)) {
      updatedRecords.add(
        NutritionRecord(
          date: dateStr,
          consumedCalories: 0,
          consumedProtein: 0,
          consumedCarbs: 0,
          consumedFat: 0,
          targetCalories: calories,
          targetProtein: protein,
          targetCarbs: carbs,
          targetFat: fat,
        ),
      );
    }

    return Nutrition(id: id, userId: userId, records: updatedRecords);
  }
}
