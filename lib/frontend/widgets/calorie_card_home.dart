import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../frontend/screens/calorie_tracking_screen.dart';
import 'incomplete_profile_dialog.dart';

class CalorieCardHome extends StatelessWidget {
  final double caloriesTaken;
  final double userCaloriesGoal;
  final double totalProteinTaken;
  final double totalCarbsTaken;
  final double totalFatsTaken;
  final double userProteinGoal;
  final double userCarbsGoal;
  final double userFatsGoal;

  const CalorieCardHome({
    super.key,
    required this.caloriesTaken,
    required this.userCaloriesGoal,
    required this.totalProteinTaken,
    required this.totalCarbsTaken,
    required this.totalFatsTaken,
    required this.userProteinGoal,
    required this.userCarbsGoal,
    required this.userFatsGoal,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('userId');

        if (userId != null) {
          final userDoc = await FirebaseFirestore.instance.collection('User').doc(userId).get();

          if (!context.mounted) return;

          if (userDoc.exists) {
            final data = userDoc.data()!;
            final hasAllFields = (data['Age'] ?? 0) > 0 &&
                (data['Weight'] ?? 0) > 0 &&
                (data['Height'] ?? 0) > 0 &&
                (data['Gender'] != null && data['Gender'].toString().trim().isNotEmpty);

            if (hasAllFields) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CalorieTrackingScreen()),
              );
            } else {
              showDialog(
                context: context,
                builder: (_) => const IncompleteProfileDialog(),
              );
            }
          }
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FCE6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: SizedBox(
                height: 150,
                child: SfRadialGauge(
                  axes: <RadialAxis>[
                    RadialAxis(
                      radiusFactor: 0.9,
                      minimum: 0,
                      maximum: userCaloriesGoal,
                      showLabels: false,
                      showTicks: false,
                      startAngle: 180,
                      endAngle: 0,
                      axisLineStyle: AxisLineStyle(
                        thickness: 0.2,
                        color: Colors.orange.shade100,
                        thicknessUnit: GaugeSizeUnit.factor,
                      ),
                      pointers: <GaugePointer>[
                        RangePointer(
                          value: caloriesTaken,
                          width: 0.2,
                          color: Colors.deepOrange,
                          cornerStyle: CornerStyle.bothCurve,
                          sizeUnit: GaugeSizeUnit.factor,
                        ),
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                          angle: 90,
                          positionFactor: 0.1,
                          widget: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${caloriesTaken.toInt()} Kcal',
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              Text('of ${userCaloriesGoal.toInt()} kcal',
                                  style: const TextStyle(fontSize: 14, color: Colors.black54)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNutrientLine("Protein", totalProteinTaken, userProteinGoal, Colors.green),
                  _buildNutrientLine("Carbs", totalCarbsTaken, userCarbsGoal, Colors.orange),
                  _buildNutrientLine("Fat", totalFatsTaken, userFatsGoal, Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientLine(String label, double value, double target, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          LinearProgressIndicator(
            value: (value / target).clamp(0.0, 1.0),
            color: color,
            backgroundColor: Colors.grey.shade200,
            minHeight: 5,
          ),
          const SizedBox(height: 2),
          Text('${value.toInt()} / ${target.toInt()}g', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
