// stat_card.dart
import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(value,
            style: TextStyle(color: color, fontSize: 26,
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label,
            style: const TextStyle(color: AppColors.muted,
              fontSize: 9, letterSpacing: 1.5)),
        ],
      ),
    );
  }
}
