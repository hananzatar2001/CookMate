import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final String? selectedValue;
  final ValueChanged<String?>? onChanged;
  final Color backgroundColor;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // التحقق إذا selectedValue موجودة في items، إذا لا يتم تمرير null
    final safeSelectedValue = (selectedValue != null && items.contains(selectedValue))
        ? selectedValue
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<String>(
        value: safeSelectedValue,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
      ),
    );
  }
}
