class UserModel {
  final String userId;
  final String name;
  final String email;
  final String Bio;
  final String Gender;
  final int Age;
  final int Height;
  final int Weight;
  final String Diseases;
  final String specificAllergies;
  final bool isVegetarian;
  final String passwordHash;



  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.Bio,
    required this.Gender,
    required this.Age,
    required this.Height,
    required this.Weight,
    required this.Diseases,
    required this.specificAllergies,
    required this.isVegetarian,
    required this.passwordHash,
  });


  factory UserModel.fromMap(Map<String, dynamic> data, String docId) {
    return UserModel(
      userId: data['user_id'] ?? docId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      Bio: data['Bio'] ?? '',
      Gender: data['Gender'] ?? '',
      Height: _parseInt(data['Height']),
      Weight: _parseInt(data['Weight']),
      Age: _parseInt(data['Age']),
      Diseases: data['Diseases'] ?? '',
      specificAllergies: data['specific_allergies'] ?? '',
      isVegetarian: data['Are_you_a_vegetarian?'] == 'yes',
      passwordHash: data['password_hash'] ?? '',

    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }


  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'Bio': Bio,
      'Gender': Gender,
      'Height': Height,
      'Weight': Weight,
      'Age': Age,
      'Diseases': Diseases,
      'specific_allergies': specificAllergies,
      'Are_you_a_vegetarian?': isVegetarian ? 'yes' : 'no',
      'password_hash': passwordHash,
    };
  }

}
