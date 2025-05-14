import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String? password;
  final int dailyCalorieTarget;
  final int dailyProteinTarget;
  final int dailyCarbsTarget;
  final int dailyFatTarget;

  final int age;
  final int weight;
  final String gender;
  final int height;
  final String? disease;
  final String? allergy;
  final bool isVegetarian;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.password,
    required this.dailyCalorieTarget,
    required this.dailyProteinTarget,
    required this.dailyCarbsTarget,
    required this.dailyFatTarget,
    required this.age,
    required this.weight,
    required this.gender,
    required this.height,
    this.disease,
    this.allergy,
    required this.isVegetarian,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      dailyCalorieTarget: json['dailyCalorieTarget'] ?? 2000,
      dailyProteinTarget: json['dailyProteinTarget'] ?? 100,
      dailyCarbsTarget: json['dailyCarbsTarget'] ?? 250,
      dailyFatTarget: json['dailyFatTarget'] ?? 65,
      age: json['age'] ?? 18,
      weight: json['weight'] ?? 180,
      gender: json['gender'] ?? 'female',
      height: json['height'] ?? 180,
      disease: json['disease'],
      allergy: json['allergy'],
      isVegetarian: json['isVegetarian'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'dailyCalorieTarget': dailyCalorieTarget,
      'dailyProteinTarget': dailyProteinTarget,
      'dailyCarbsTarget': dailyCarbsTarget,
      'dailyFatTarget': dailyFatTarget,
      'age': age,
      'weight': weight,
      'gender': gender,
      'height': height,
      'disease': disease,
      'allergy': allergy,
      'isVegetarian': isVegetarian,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    int? dailyCalorieTarget,
    int? dailyProteinTarget,
    int? dailyCarbsTarget,
    int? dailyFatTarget,
    int? age,
    int? weight,
    String? gender,
    int? height,
    String? disease,
    String? allergy,
    bool? isVegetarian,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      dailyCalorieTarget: dailyCalorieTarget ?? this.dailyCalorieTarget,
      dailyProteinTarget: dailyProteinTarget ?? this.dailyProteinTarget,
      dailyCarbsTarget: dailyCarbsTarget ?? this.dailyCarbsTarget,
      dailyFatTarget: dailyFatTarget ?? this.dailyFatTarget,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      disease: disease ?? this.disease,
      allergy: allergy ?? this.allergy,
      isVegetarian: isVegetarian ?? this.isVegetarian,
    );
  }
}
