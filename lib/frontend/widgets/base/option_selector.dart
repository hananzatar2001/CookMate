import 'package:flutter/material.dart';

class OptionSelector extends StatelessWidget {
  final String label;

  final String selectedValue;

  final Map<String, String> options;

  final Function(String) onChanged;

  final Color primaryColor;

  final Color backgroundColor;

  const OptionSelector({
    Key? key,
    required this.label,
    required this.selectedValue,
    required this.options,
    required this.onChanged,
    required this.primaryColor,
    this.backgroundColor = const Color(0xFFF5F5F5),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final optionKeys = options.keys.toList();

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Row(
            children: List.generate(optionKeys.length, (index) {
              final optionValue = optionKeys[index];
              final displayText = options[optionValue]!;
              final isSelected = selectedValue == optionValue;

              return GestureDetector(
                onTap: () => onChanged(optionValue),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.horizontal(
                      left: index == 0 ? const Radius.circular(8) : Radius.zero,
                      right:
                          index == optionKeys.length - 1
                              ? const Radius.circular(8)
                              : Radius.zero,
                    ),
                  ),
                  child: Text(
                    displayText,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
