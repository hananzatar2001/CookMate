import 'package:flutter/material.dart';

class SavedPageCategoryFilter extends StatefulWidget {
  final List<String> categories;

  const SavedPageCategoryFilter({super.key, required this.categories});

  @override
  State<SavedPageCategoryFilter> createState() => _SavedPageCategoryFilterState();
}

class _SavedPageCategoryFilterState extends State<SavedPageCategoryFilter> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: widget.categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final isSelected = index == selectedIndex;
            return ChoiceChip(
              label: Text(
                widget.categories[index],
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,

                ),
              ),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  selectedIndex = index;
                });
              },
              selectedColor: Colors.white,
              backgroundColor: isSelected
                  ? Colors.white
                  : const Color(0xFFEFEFEF),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: const BorderSide(
                  color: Colors.transparent,
                ),
              ),
              shadowColor: Colors.black12,
              pressElevation: 0,
              showCheckmark: false,
            );
          },
        ),
      ),
    );
  }
}
