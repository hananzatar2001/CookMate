import 'package:flutter/material.dart';

class RecipeCard extends StatelessWidget {
  final String title;
  final String imageUrl;

  const RecipeCard({
    Key? key,
    required this.title,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xFFFBFEEC),
        border: Border.all(
          color: const Color(0xFF333333),
          width: 0.4,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 6),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ✅ الصورة
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF333333),
                width: 0.4,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(width: 12), // ✅ مسافة بين الصورة والنص

          // ✅ النص بجانب الصورة بمحاذاة يسار
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // يمكنك إضافة زر الحفظ هنا مثلاً لاحقاً
        ],
      ),
    );
  }
}
