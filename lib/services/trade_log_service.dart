import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

class Trade {
  final int number;
  final DateTime time;
  final String outcome; // WIN, LOSS, UNKNOWN

  Trade({required this.number, required this.time, required this.outcome});
}

class TradeLogService {
  final List<Trade> _trades = [];
  List<Trade> get trades => List.unmodifiable(_trades);

  int get totalTrades => _trades.length;
  int get wins => _trades.where((t) => t.outcome == 'WIN').length;
  int get losses => _trades.where((t) => t.outcome == 'LOSS').length;
  double get winRate => totalTrades == 0 ? 0 : wins / totalTrades;

  void addTrade(int number, String outcome) {
    _trades.add(Trade(
      number: number,
      time: DateTime.now(),
      outcome: outcome,
    ));
  }

  void clear() => _trades.clear();

  Future<String> exportCsv() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/iqoption-trades.csv');

    final rows = [
      ['Trade #', 'Time', 'Outcome'],
      ..._trades.map((t) => [
        t.number,
        t.time.toIso8601String(),
        t.outcome,
      ]),
    ];

    final csv = const ListToCsvConverter().convert(rows);
    await file.writeAsString(csv);
    return file.path;
  }
}
