import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/bot_service.dart';
import '../services/settings_service.dart';
import '../services/trade_log_service.dart';
import '../services/theme_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/interval_control.dart';
import '../widgets/log_view.dart';
import '../widgets/permission_row.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final BotService _bot = BotService();
  final SettingsService _settings = SettingsService();
  final TradeLogService _log = TradeLogService();

  bool _running = false;
  bool _overlayGranted = false;
  bool _accessibilityGranted = false;
  int _intervalSec = 120;
  double _confidence = 0.8;
  String _imagePath = '';
  String _imageLabel = 'No image selected...';
  int _clicks = 0;
  int _missed = 0;
  int _countdown = 0;
  int _runtime = 0;
  bool _soundEnabled = true;

  final List<Map<String, String>> _logs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initSettings();
    _setupBotCallbacks();
    _checkPermissions();
  }

  Future<void> _initSettings() async {
    await _settings.init();
    setState(() {
      _intervalSec = _settings.interval;
      _confidence  = _settings.confidence;
      _imagePath   = _settings.imagePath;
      _soundEnabled = _settings.soundEnabled;
      if (_imagePath.isNotEmpty) {
        _imageLabel = _imagePath.split('/').last;
      }
    });
  }

  void _setupBotCallbacks() {
    _bot.onClicked = (time) => setState(() {
      _clicks = _bot.clicks;
      _addLog('✅ Clicked Higher at $time', 'success');
    });
    _bot.onMissed = () => setState(() {
      _missed = _bot.missed;
      _addLog('❌ Button not found', 'error');
    });
    _bot.onCountdown = (r) => setState(() => _countdown = r);
    _bot.onRuntimeUpdate = (m) => setState(() => _runtime = m);
    _bot.onLog = (msg, level) => setState(() => _addLog(msg, level));
  }

  void _addLog(String msg, String level) {
    _logs.insert(0, {'msg': msg, 'level': level,
      'time': TimeOfDay.now().format(context)});
    if (_logs.length > 50) _logs.removeLast();
  }

  Future<void> _checkPermissions() async {
    final overlay = await Permission.systemAlertWindow.isGranted;
    setState(() {
      _overlayGranted = overlay;
      _accessibilityGranted = false; // checked via platform channel
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _imagePath = file.path;
        _imageLabel = file.name;
      });
      await _settings.setImagePath(file.path);
      _addLog('✅ Image loaded: ${file.name}', 'success');
    }
  }

  void _setInterval(int sec) {
    setState(() => _intervalSec = sec.clamp(10, 3600));
    _settings.setInterval(_intervalSec);
  }

  Future<void> _toggleBot() async {
    if (_running) {
      _bot.stop();
      setState(() => _running = false);
    } else {
      if (_imagePath.isEmpty) {
        _showSnack('Please select the Higher button image first');
        return;
      }
      if (!_overlayGranted) {
        _showSnack('Please grant Overlay permission first');
        await Permission.systemAlertWindow.request();
        _checkPermissions();
        return;
      }
      _bot.configure(
        imagePath: _imagePath,
        intervalSec: _intervalSec,
        confidence: _confidence,
      );
      await _bot.start();
      setState(() {
        _running = true;
        _clicks = 0;
        _missed = 0;
        _runtime = 0;
      });
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, style: const TextStyle(color: AppColors.bg)),
               backgroundColor: AppColors.accent));
  }

  String _formatTime(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBotTab(),
                  _buildHistoryTab(),
                  _buildSettingsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(
              color: _running ? AppColors.green : AppColors.muted,
              shape: BoxShape.circle,
              boxShadow: _running ? [BoxShadow(
                color: AppColors.green.withOpacity(0.5), blurRadius: 8)] : [],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text('IQ OPTION BOT',
              style: TextStyle(color: AppColors.accent,
                fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
          ),
          Text('v1.0.0',
            style: TextStyle(color: AppColors.muted, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.accent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.accent.withOpacity(0.3)),
        ),
        labelColor: AppColors.accent,
        unselectedLabelColor: AppColors.muted,
        labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        tabs: const [
          Tab(text: 'BOT'),
          Tab(text: 'HISTORY'),
          Tab(text: 'SETTINGS'),
        ],
      ),
    );
  }

  Widget _buildBotTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status card
          _buildStatusCard(),
          const SizedBox(height: 12),

          // Stats row
          Row(children: [
            Expanded(child: StatCard(label: 'CLICKS', value: '$_clicks', color: AppColors.accent)),
            const SizedBox(width: 10),
            Expanded(child: StatCard(label: 'MISSED', value: '$_missed', color: AppColors.red)),
            const SizedBox(width: 10),
            Expanded(child: StatCard(label: 'RUNTIME', value: '${_runtime}m', color: AppColors.muted)),
          ]),
          const SizedBox(height: 16),

          // Permissions
          PermissionRow(
            label: 'Overlay Permission',
            subtitle: 'Draw over other apps',
            granted: _overlayGranted,
            onTap: () async {
              await Permission.systemAlertWindow.request();
              _checkPermissions();
            },
          ),
          const SizedBox(height: 8),
          PermissionRow(
            label: 'Accessibility Service',
            subtitle: 'Required to tap IQ Option',
            granted: _accessibilityGranted,
            onTap: () {
              _showSnack('Enable "IQ Option Bot" in Accessibility Settings');
            },
          ),
          const SizedBox(height: 16),

          // Image picker
          _buildSectionLabel('HIGHER BUTTON IMAGE'),
          _buildImagePicker(),
          const SizedBox(height: 16),

          // Interval
          _buildSectionLabel('CLICK INTERVAL'),
          IntervalControl(
            intervalSec: _intervalSec,
            onChanged: _setInterval,
          ),
          const SizedBox(height: 16),

          // Start/Stop button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _toggleBot,
              style: ElevatedButton.styleFrom(
                backgroundColor: _running ? AppColors.red : AppColors.green,
                foregroundColor: _running ? Colors.white : AppColors.bg,
              ),
              child: Text(_running
                ? '■  STOP BOT'
                : '▶  START BOT',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
                  letterSpacing: 1)),
            ),
          ),
          const SizedBox(height: 16),

          // Log
          _buildSectionLabel('ACTIVITY LOG'),
          LogView(logs: _logs),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: _running ? AppColors.green : AppColors.muted,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _running ? 'RUNNING — ACTIVE' : 'IDLE — NOT RUNNING',
                  style: TextStyle(
                    color: _running ? AppColors.green : AppColors.muted,
                    fontSize: 11, fontWeight: FontWeight.bold),
                ),
                if (_running)
                  Text('next click: ${_formatTime(_countdown)}',
                    style: const TextStyle(color: AppColors.accent, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(_imageLabel,
              style: TextStyle(
                color: _imagePath.isEmpty ? AppColors.muted : AppColors.text,
                fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: _pickImage,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              side: const BorderSide(color: AppColors.accent),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Browse', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return HistoryScreen(logService: _log);
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel('MATCH CONFIDENCE'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Text('LOW', style: TextStyle(color: AppColors.muted, fontSize: 10)),
                Expanded(
                  child: Slider(
                    value: _confidence,
                    min: 0.5, max: 0.99, divisions: 49,
                    onChanged: (v) {
                      setState(() => _confidence = v);
                      _settings.setConfidence(v);
                    },
                  ),
                ),
                const Text('HIGH', style: TextStyle(color: AppColors.muted, fontSize: 10)),
                const SizedBox(width: 8),
                Text('${(_confidence * 100).round()}%',
                  style: const TextStyle(color: AppColors.accent,
                    fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionLabel('SOUND ALERTS'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: SwitchListTile(
              title: const Text('Enable sounds',
                style: TextStyle(color: AppColors.text, fontSize: 13)),
              subtitle: const Text('Vibrate + sound on click',
                style: TextStyle(color: AppColors.muted, fontSize: 10)),
              value: _soundEnabled,
              activeColor: AppColors.accent,
              onChanged: (v) {
                setState(() => _soundEnabled = v);
                _settings.setSoundEnabled(v);
              },
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ABOUT', style: TextStyle(color: AppColors.muted,
                  fontSize: 9, letterSpacing: 2)),
                const SizedBox(height: 8),
                const Text('IQ Option Bot v1.0.0',
                  style: TextStyle(color: AppColors.text, fontSize: 13)),
                const SizedBox(height: 4),
                const Text('Flutter cross-platform edition',
                  style: TextStyle(color: AppColors.muted, fontSize: 11)),
                const SizedBox(height: 4),
                Text('DIGITALFINTECHSOLUTIONS',
                  style: TextStyle(color: AppColors.accent2, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label,
        style: const TextStyle(color: AppColors.muted, fontSize: 9, letterSpacing: 2)),
    );
  }

  @override
  void dispose() {
    _bot.stop();
    _tabController.dispose();
    super.dispose();
  }
}
