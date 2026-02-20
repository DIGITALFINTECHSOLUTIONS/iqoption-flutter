import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class LogView extends StatelessWidget {
  final List<Map<String, String>> logs;
  const LogView({super.key, required this.logs});

  Color _levelColor(String level) {
    switch (level) {
      case 'success': return AppColors.green;
      case 'error':   return AppColors.red;
      case 'warn':    return AppColors.yellow;
      default:        return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: logs.isEmpty
        ? const Center(child: Text('— Ready. Grant permissions and press START.',
            style: TextStyle(color: AppColors.muted, fontSize: 10)))
        : ListView.builder(
            itemCount: logs.length,
            itemBuilder: (ctx, i) {
              final log = logs[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(log['msg'] ?? '',
                  style: TextStyle(
                    color: _levelColor(log['level'] ?? 'info'),
                    fontSize: 10),
                ),
              );
            },
          ),
    );
  }
}
