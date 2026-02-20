import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class BotService {
  static const _channel = MethodChannel('com.iqbot.flutter/bot');

  bool _running = false;
  int _intervalSec = 120;
  String _imagePath = '';
  double _confidence = 0.8;

  int clicks = 0;
  int missed = 0;
  int wins = 0;
  int losses = 0;

  Timer? _botTimer;
  Timer? _countdownTimer;
  int _countdown = 0;
  DateTime? _startTime;

  // Callbacks
  Function(String time)? onClicked;
  Function()? onMissed;
  Function(String time, String result)? onOutcome;
  Function(int remaining)? onCountdown;
  Function(int minutes)? onRuntimeUpdate;
  Function(String msg, String level)? onLog;

  bool get isRunning => _running;
  int get countdown => _countdown;

  void configure({
    required String imagePath,
    required int intervalSec,
    required double confidence,
  }) {
    _imagePath = imagePath;
    _intervalSec = intervalSec;
    _confidence = confidence;
  }

  Future<void> start() async {
    if (_running) return;
    _running = true;
    _startTime = DateTime.now();
    clicks = 0;
    missed = 0;
    wins = 0;
    losses = 0;
    _countdown = _intervalSec;

    _log('🚀 Bot started — interval: ${_formatTime(_intervalSec)}', 'success');

    // Request overlay permission and start accessibility service
    await _channel.invokeMethod('startBot', {
      'imagePath': _imagePath,
      'intervalSec': _intervalSec,
      'confidence': _confidence,
    });

    _startCountdown();
    _startRuntimeUpdater();

    // Schedule first click
    _scheduleClick();
  }

  void stop() {
    _running = false;
    _botTimer?.cancel();
    _countdownTimer?.cancel();
    _channel.invokeMethod('stopBot');
    _log('⏹ Bot stopped.', 'info');
  }

  void _scheduleClick() {
    if (!_running) return;
    _countdown = _intervalSec;
    _botTimer = Timer(Duration(seconds: _intervalSec), () {
      if (_running) _doClick();
    });
  }

  Future<void> _doClick() async {
    if (!_running) return;
    try {
      // Call native method to take screenshot + find + tap
      final result = await _channel.invokeMethod('findAndTap', {
        'imagePath': _imagePath,
        'confidence': _confidence,
      });

      if (result == true) {
        clicks++;
        final time = _timeNow();
        _log('✅ Clicked Higher at $time', 'success');
        onClicked?.call(time);
      } else {
        missed++;
        _log('❌ Higher button not found', 'error');
        onMissed?.call();
      }
    } catch (e) {
      missed++;
      _log('⚠️ Error: $e', 'warn');
      onMissed?.call();
    }

    _countdown = _intervalSec;
    _scheduleClick();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_running) return;
      _countdown = (_countdown - 1).clamp(0, _intervalSec);
      onCountdown?.call(_countdown);
    });
  }

  void _startRuntimeUpdater() {
    Timer.periodic(const Duration(seconds: 30), (t) {
      if (!_running) { t.cancel(); return; }
      final minutes = DateTime.now().difference(_startTime!).inMinutes;
      onRuntimeUpdate?.call(minutes);
    });
  }

  void _log(String msg, String level) {
    onLog?.call(msg, level);
  }

  String _timeNow() {
    final n = DateTime.now();
    return '${n.hour.toString().padLeft(2,'0')}:${n.minute.toString().padLeft(2,'0')}:${n.second.toString().padLeft(2,'0')}';
  }

  String _formatTime(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '$m:${s.toString().padLeft(2,'0')}';
  }
}
