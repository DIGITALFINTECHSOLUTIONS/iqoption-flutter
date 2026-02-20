import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class PermissionRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool granted;
  final VoidCallback onTap;

  const PermissionRow({
    super.key,
    required this.label,
    required this.subtitle,
    required this.granted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: granted ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                color: granted ? AppColors.green : AppColors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                    style: const TextStyle(color: AppColors.text, fontSize: 13)),
                  Text(subtitle,
                    style: const TextStyle(color: AppColors.muted, fontSize: 10)),
                ],
              ),
            ),
            if (!granted)
              const Text('TAP →',
                style: TextStyle(color: AppColors.accent,
                  fontSize: 10, fontWeight: FontWeight.bold)),
            if (granted)
              const Icon(Icons.check_circle, color: AppColors.green, size: 18),
          ],
        ),
      ),
    );
  }
}
