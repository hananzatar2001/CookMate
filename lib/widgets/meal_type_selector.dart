import 'package:flutter/material.dart';

class MealTypeSelector extends StatelessWidget {
  final String selectedMealType;
  final Function(String) onMealTypeSelected;
  final List<String> mealTypes;
  final bool plainMode;
  const MealTypeSelector({
    super.key,
    required this.selectedMealType,
    required this.onMealTypeSelected,
    this.mealTypes = const ['Breakfast', 'Lunch', 'Dinner', 'Snacks'],
    this.plainMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final fontSize = screenWidth < 360 ? 14.0 : 16.0;

    final horizontalPadding = screenWidth < 360 ? 2.0 : 8.0;

    return plainMode
        ? Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 8.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:
                mealTypes
                    .map(
                      (mealType) =>
                          _buildMealTypeButton(mealType, context, fontSize),
                    )
                    .toList(),
          ),
        )
        : Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 8.0,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(50.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),

                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 4.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:
                    mealTypes
                        .map(
                          (mealType) =>
                              _buildMealTypeButton(mealType, context, fontSize),
                        )
                        .toList(),
              ),
            ),
          ),
        );
  }

  Widget _buildMealTypeButton(
    String mealType,
    BuildContext context,
    double fontSize,
  ) {
    final isSelected = selectedMealType == mealType;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          onMealTypeSelected(mealType);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$mealType selected'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        child:
            plainMode
                ? Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 2.0,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          mealType,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            fontSize: fontSize,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isSelected)
                          Container(
                            margin: const EdgeInsets.only(top: 4.0),
                            height: 2.0,
                            width: 40.0,
                            color: Colors.black,
                          ),
                      ],
                    ),
                  ),
                )
                : AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 2.0,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(50.0),
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.6),

                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                              BoxShadow(
                                color: Colors.white,
                                spreadRadius: -1,
                                blurRadius: 4,
                                offset: const Offset(0, -1),
                              ),
                            ]
                            : null,
                  ),
                  child: Center(
                    child: Text(
                      mealType,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: fontSize,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
      ),
    );
  }
}
