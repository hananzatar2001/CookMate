class Favorites {
  final String id;
  final String userId;
  final List<String> recipeIds;

  Favorites({required this.id, required this.userId, required this.recipeIds});

  factory Favorites.fromJson(Map<String, dynamic> json) {
    return Favorites(
      id: json['id'],
      userId: json['userId'],
      recipeIds: List<String>.from(json['recipeIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'userId': userId, 'recipeIds': recipeIds};
  }

  Favorites addRecipe(String recipeId) {
    if (recipeIds.contains(recipeId)) {
      return this;
    }

    final updatedRecipeIds = List<String>.from(recipeIds)..add(recipeId);
    return Favorites(id: id, userId: userId, recipeIds: updatedRecipeIds);
  }

  Favorites removeRecipe(String recipeId) {
    final updatedRecipeIds = List<String>.from(recipeIds)
      ..removeWhere((id) => id == recipeId);

    return Favorites(id: id, userId: userId, recipeIds: updatedRecipeIds);
  }

  Favorites copyWith({String? id, String? userId, List<String>? recipeIds}) {
    return Favorites(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      recipeIds: recipeIds ?? this.recipeIds,
    );
  }
}
