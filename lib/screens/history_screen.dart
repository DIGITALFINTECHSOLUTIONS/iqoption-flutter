import 'package:flutter/material.dart';
import '../services/trade_log_service.dart';
import '../services/theme_service.dart';

class HistoryScreen extends StatelessWidget {
  final TradeLogService logService;
  const HistoryScreen({super.key, required this.logService});

  @override
  Widget build(BuildContext context) {
    final trades = logService.trades;
    final winRate = logService.winRate;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Win rate bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('WIN RATE', style: TextStyle(color: AppColors.muted,
                      fontSize: 9, letterSpacing: 2)),
                    Text('${(winRate * 100).round()}%',
                      style: TextStyle(color: AppColors.green,
                        fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: winRate,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation(AppColors.green),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${logService.wins} wins',
                      style: const TextStyle(color: AppColors.green, fontSize: 11)),
                    Text('${logService.totalTrades} total',
                      style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                    Text('${logService.losses} losses',
                      style: const TextStyle(color: AppColors.red, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Export button
          OutlinedButton.icon(
            onPressed: trades.isEmpty ? null : () async {
              final path = await logService.exportCsv();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Saved to: $path',
                    style: const TextStyle(color: AppColors.bg)),
                    backgroundColor: AppColors.accent));
              }
            },
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Export CSV', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              side: const BorderSide(color: AppColors.accent),
            ),
          ),
          const SizedBox(height: 12),

          // Trade list
          Expanded(
            child: trades.isEmpty
              ? Center(child: Text('No trades yet.\nStart the bot to record trades.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted, fontSize: 13)))
              : ListView.builder(
                  itemCount: trades.length,
                  itemBuilder: (ctx, i) {
                    final t = trades[trades.length - 1 - i];
                    return _TradeRow(trade: t);
                  },
                ),
          ),
        ],
      ),
    );
  }
}

class _TradeRow extends StatelessWidget {
  final Trade trade;
  const _TradeRow({required this.trade});

  @override
  Widget build(BuildContext context) {
    final color = trade.outcome == 'WIN' ? AppColors.green
      : trade.outcome == 'LOSS' ? AppColors.red : AppColors.muted;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text('#${trade.number}',
            style: TextStyle(color: AppColors.muted, fontSize: 11)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${trade.time.hour.toString().padLeft(2,'0')}:'
              '${trade.time.minute.toString().padLeft(2,'0')}:'
              '${trade.time.second.toString().padLeft(2,'0')}',
              style: const TextStyle(color: AppColors.text, fontSize: 11)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Text(trade.outcome,
              style: TextStyle(color: color,
                fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
