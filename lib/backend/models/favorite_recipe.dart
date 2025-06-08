class FavoriteRecipe {
  final String id;
  final String title;
  final String imageUrl;

  FavoriteRecipe({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  factory FavoriteRecipe.fromMap(Map<String, dynamic> data, String docId) {
    return FavoriteRecipe(
      id: docId,
      title: data['title'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}
