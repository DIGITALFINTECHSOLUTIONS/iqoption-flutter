import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class IntervalControl extends StatelessWidget {
  final int intervalSec;
  final ValueChanged<int> onChanged;

  const IntervalControl({
    super.key,
    required this.intervalSec,
    required this.onChanged,
  });

  String _format(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(_format(intervalSec),
                style: const TextStyle(color: AppColors.accent,
                  fontSize: 36, fontWeight: FontWeight.bold)),
              const Spacer(),
              Column(
                children: [
                  _AdjustBtn('+30s', () => onChanged(intervalSec + 30)),
                  const SizedBox(height: 6),
                  _AdjustBtn('-30s', () => onChanged(intervalSec - 30)),
                ],
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  _AdjustBtn('+5s', () => onChanged(intervalSec + 5)),
                  const SizedBox(height: 6),
                  _AdjustBtn('-5s', () => onChanged(intervalSec - 5)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Presets
          Row(
            children: [
              _Preset('30s',  30,  intervalSec, onChanged),
              const SizedBox(width: 6),
              _Preset('2m',   120, intervalSec, onChanged),
              const SizedBox(width: 6),
              _Preset('5m',   300, intervalSec, onChanged),
              const SizedBox(width: 6),
              _Preset('10m',  600, intervalSec, onChanged),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdjustBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _AdjustBtn(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60, height: 32,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: AppColors.text,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 10)),
      ),
    );
  }
}

class _Preset extends StatelessWidget {
  final String label;
  final int value;
  final int current;
  final ValueChanged<int> onTap;
  const _Preset(this.label, this.value, this.current, this.onTap);

  @override
  Widget build(BuildContext context) {
    final active = current == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.accent2.withOpacity(0.15) : AppColors.surface2,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: active ? AppColors.accent2 : AppColors.border),
          ),
          alignment: Alignment.center,
          child: Text(label,
            style: TextStyle(
              color: active ? AppColors.accent2 : AppColors.muted,
              fontSize: 11, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
