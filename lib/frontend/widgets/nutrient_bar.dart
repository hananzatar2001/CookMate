import 'package:flutter/material.dart';

class NutrientBar extends StatelessWidget {
  final String label;
  final double  value;
  final double  target;
  final Color color;

  const NutrientBar({
    super.key,
    required this.label,
    required this.value,
    required this.target,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    double progress = value / target;

    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                color: color,
                strokeWidth: 4,
              ),
              Text('${value.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}