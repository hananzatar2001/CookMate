import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileCollectionRecipesSectionModel {
  final String id;
  final String title;
  final String imageUrl;

  ProfileCollectionRecipesSectionModel({
    required this.id,
    required this.title,
    required this.imageUrl,
  });


  factory ProfileCollectionRecipesSectionModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProfileCollectionRecipesSectionModel(
      id: doc.id,
      title: data['title'] ?? 'No Title',
      imageUrl: data['image_url'] ?? '',
    );
  }


  factory ProfileCollectionRecipesSectionModel.fromMap(Map<String, dynamic> map) {
    return ProfileCollectionRecipesSectionModel(
      id: map['id'].toString(),
      title: map['title'] ?? 'No Title',
      imageUrl: map['image_url'] ?? '',
    );
  }
}
