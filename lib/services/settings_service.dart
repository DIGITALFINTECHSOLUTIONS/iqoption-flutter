import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _keyInterval   = 'interval';
  static const _keyImagePath  = 'image_path';
  static const _keyConfidence = 'confidence';
  static const _keySound      = 'sound';
  static const _keyLogPath    = 'log_path';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  int get interval    => _prefs.getInt(_keyInterval) ?? 120;
  String get imagePath => _prefs.getString(_keyImagePath) ?? '';
  double get confidence => _prefs.getDouble(_keyConfidence) ?? 0.8;
  bool get soundEnabled => _prefs.getBool(_keySound) ?? true;
  String get logPath  => _prefs.getString(_keyLogPath) ?? '';

  Future<void> setInterval(int v)    async => _prefs.setInt(_keyInterval, v);
  Future<void> setImagePath(String v) async => _prefs.setString(_keyImagePath, v);
  Future<void> setConfidence(double v) async => _prefs.setDouble(_keyConfidence, v);
  Future<void> setSoundEnabled(bool v) async => _prefs.setBool(_keySound, v);
  Future<void> setLogPath(String v)  async => _prefs.setString(_keyLogPath, v);
}
