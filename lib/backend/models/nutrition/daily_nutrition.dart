class DailyNutrition {
  final String id;
  final DateTime date;
  final int consumedCalories;
  final int consumedProtein;
  final int consumedCarbs;
  final int consumedFat;
  final int consumedFiber;

  DailyNutrition({
    required this.id,
    required this.date,
    required this.consumedCalories,
    required this.consumedProtein,
    required this.consumedCarbs,
    required this.consumedFat,
    required this.consumedFiber,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'consumedCalories': consumedCalories,
      'consumedProtein': consumedProtein,
      'consumedCarbs': consumedCarbs,
      'consumedFat': consumedFat,
      'consumedFiber': consumedFiber,
    };
  }

  factory DailyNutrition.fromJson(Map<String, dynamic> json) {
    return DailyNutrition(
      id: json['id'],
      date: DateTime.parse(json['date']),
      consumedCalories: json['consumedCalories'],
      consumedProtein: json['consumedProtein'],
      consumedCarbs: json['consumedCarbs'],
      consumedFat: json['consumedFat'],
      consumedFiber: json['consumedFiber'] ?? 0,
    );
  }

  DailyNutrition copyWith({
    String? id,
    DateTime? date,
    int? consumedCalories,
    int? consumedProtein,
    int? consumedCarbs,
    int? consumedFat,
    int? consumedFiber,
  }) {
    return DailyNutrition(
      id: id ?? this.id,
      date: date ?? this.date,
      consumedCalories: consumedCalories ?? this.consumedCalories,
      consumedProtein: consumedProtein ?? this.consumedProtein,
      consumedCarbs: consumedCarbs ?? this.consumedCarbs,
      consumedFat: consumedFat ?? this.consumedFat,
      consumedFiber: consumedFiber ?? this.consumedFiber,
    );
  }

  DailyNutrition addNutrition({
    int? calories,
    int? protein,
    int? carbs,
    int? fat,
    int? fiber,
  }) {
    return copyWith(
      consumedCalories: consumedCalories + (calories ?? 0),
      consumedProtein: consumedProtein + (protein ?? 0),
      consumedCarbs: consumedCarbs + (carbs ?? 0),
      consumedFat: consumedFat + (fat ?? 0),
      consumedFiber: consumedFiber + (fiber ?? 0),
    );
  }

  DailyNutrition subtractNutrition({
    int? calories,
    int? protein,
    int? carbs,
    int? fat,
    int? fiber,
  }) {
    return copyWith(
      consumedCalories:
          (consumedCalories - (calories ?? 0))
              .clamp(0, double.infinity)
              .toInt(),
      consumedProtein:
          (consumedProtein - (protein ?? 0)).clamp(0, double.infinity).toInt(),
      consumedCarbs:
          (consumedCarbs - (carbs ?? 0)).clamp(0, double.infinity).toInt(),
      consumedFat: (consumedFat - (fat ?? 0)).clamp(0, double.infinity).toInt(),
      consumedFiber:
          (consumedFiber - (fiber ?? 0)).clamp(0, double.infinity).toInt(),
    );
  }
}
