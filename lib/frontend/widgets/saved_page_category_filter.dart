import 'package:flutter/material.dart';

class SavedPageCategoryFilter extends StatefulWidget {
  final Function(String) onCategorySelected;

  const SavedPageCategoryFilter({
    Key? key,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  State<SavedPageCategoryFilter> createState() => _SavedPageCategoryFilterState();
}

class _SavedPageCategoryFilterState extends State<SavedPageCategoryFilter> {
  final List<String> categories = ['All', 'Breakfast', 'Lunch', 'Dinner', 'Snack'];

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 1),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFEFEFEF),
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
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 5),
              itemBuilder: (context, index) {
                final isSelected = index == selectedIndex;
                return ChoiceChip(
                  label: Text(
                    categories[index],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      selectedIndex = index;
                    });
                    widget.onCategorySelected(categories[index]);
                  },
                  selectedColor: const Color(0xFFFAFAFA),
                  backgroundColor: const Color(0xFFEFEFEF),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: Colors.transparent),
                  ),
                  shadowColor: Colors.black12,
                  pressElevation: 0,
                  showCheckmark: false,
                );
              },
            ),
          ),
        ),


        const SizedBox(height: 35),
      ],
    );
  }
}
