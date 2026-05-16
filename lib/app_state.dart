import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RideRecord {
  final DateTime date;
  final double distance;
  final Duration duration;
  final double maxSpeed;
  final double avgSpeed;

  RideRecord({
    required this.date,
    required this.distance,
    required this.duration,
    required this.maxSpeed,
    required this.avgSpeed,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'distance': distance,
        'durationSec': duration.inSeconds,
        'maxSpeed': maxSpeed,
        'avgSpeed': avgSpeed,
      };

  factory RideRecord.fromJson(Map<String, dynamic> j) => RideRecord(
        date: DateTime.parse(j['date'] as String),
        distance: (j['distance'] as num).toDouble(),
        duration: Duration(seconds: j['durationSec'] as int),
        maxSpeed: (j['maxSpeed'] as num).toDouble(),
        avgSpeed: (j['avgSpeed'] as num).toDouble(),
      );
}

class MaintenanceEntry {
  final String title;
  final String description;
  final DateTime date;
  final String category;

  MaintenanceEntry({
    required this.title,
    required this.description,
    required this.date,
    required this.category,
  });
}

class AppState extends ChangeNotifier {
  static const platform = MethodChannel('com.example.re_app/tripper');

  // BLE
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  bool _isScanning = false;
  List<ScanResult> _scanResults = [];

  // Media
  String _currentSong = 'No music playing';
  String _currentArtist = '';
  final AudioPlayer _audioPlayer = AudioPlayer();
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<SongModel> _localSongs = [];
  bool _isPlayingLocal = false;

  // Ride Stats
  double _currentSpeed = 0.0;
  double _maxSpeed = 0.0;
  double _totalDistance = 0.0;
  double _totalSpeedSum = 0.0;
  int _speedSamples = 0;
  Duration _tripDuration = Duration.zero;
  bool _isTracking = false;
  Position? _lastPosition;
  Timer? _tripTimer;
  List<double> _speedHistory = [];

  // Ride History
  List<RideRecord> _rideHistory = [];

  // Maintenance Logs
  List<MaintenanceEntry> _maintenanceLogs = [
    MaintenanceEntry(
      title: 'Engine Oil Change',
      description: '20W-50 Motul — Workshop',
      date: DateTime.now().subtract(const Duration(days: 30)),
      category: 'Service',
    ),
    MaintenanceEntry(
      title: 'Fuel Refill',
      description: '2.5L @ ₹102.5',
      date: DateTime.now().subtract(const Duration(days: 1)),
      category: 'Fuel',
    ),
    MaintenanceEntry(
      title: 'Chain Cleaning',
      description: 'DIY with chain lube',
      date: DateTime.now().subtract(const Duration(days: 3)),
      category: 'DIY',
    ),
  ];

  // Settings
  bool _isDarkMode = true;
  bool _useMetricUnits = true;
  bool _hapticEnabled = true;
  bool _autoReconnect = true;

  // Weather
  Map<String, dynamic>? _weatherData;
  bool _isLoadingWeather = false;
  String _weatherError = '';

  // Getters — BLE
  BluetoothDevice? get connectedDevice => _connectedDevice;
  bool get isScanning => _isScanning;
  List<ScanResult> get scanResults => _scanResults;

  // Getters — Media
  String get currentSong => _currentSong;
  String get currentArtist => _currentArtist;
  List<SongModel> get localSongs => _localSongs;
  bool get isPlayingLocal => _isPlayingLocal;

  // Getters — Ride
  double get currentSpeed => _currentSpeed;
  double get maxSpeed => _maxSpeed;
  double get totalDistance => _totalDistance;
  Duration get tripDuration => _tripDuration;
  bool get isTracking => _isTracking;
  List<double> get speedHistory => List.unmodifiable(_speedHistory);
  double get avgSpeed =>
      _speedSamples > 0 ? _totalSpeedSum / _speedSamples : 0;

  // Getters — History & Maintenance
  List<RideRecord> get rideHistory => List.unmodifiable(_rideHistory);
  List<MaintenanceEntry> get maintenanceLogs =>
      List.unmodifiable(_maintenanceLogs);
  double get serviceProgressKm => 750;
  double get serviceIntervalKm => 5000;

  // Getters — Settings
  bool get isDarkMode => _isDarkMode;
  bool get useMetricUnits => _useMetricUnits;
  bool get hapticEnabled => _hapticEnabled;
  bool get autoReconnect => _autoReconnect;

  // Getters — Weather
  Map<String, dynamic>? get weatherData => _weatherData;
  bool get isLoadingWeather => _isLoadingWeather;
  String get weatherError => _weatherError;

  AppState() {
    _init();
  }

  Future<void> _init() async {
    await _loadSettings();
    _initNativeBridge();
    _initLocationTracking();
    _scanLocalMusic();
    _loadRideHistory();
    fetchWeather();
  }

  // ── Settings ──────────────────────────────────────────────────────────────
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('isDarkMode') ?? true;
      _useMetricUnits = prefs.getBool('useMetricUnits') ?? true;
      _hapticEnabled = prefs.getBool('hapticEnabled') ?? true;
      _autoReconnect = prefs.getBool('autoReconnect') ?? true;
      notifyListeners();
    } catch (e) {
      debugPrint('Load settings error: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _isDarkMode);
      await prefs.setBool('useMetricUnits', _useMetricUnits);
      await prefs.setBool('hapticEnabled', _hapticEnabled);
      await prefs.setBool('autoReconnect', _autoReconnect);
    } catch (e) {
      debugPrint('Save settings error: $e');
    }
  }

  void setDarkMode(bool v) {
    _isDarkMode = v;
    _saveSettings();
    notifyListeners();
  }

  void setMetricUnits(bool v) {
    _useMetricUnits = v;
    _saveSettings();
    notifyListeners();
  }

  void setHaptic(bool v) {
    _hapticEnabled = v;
    _saveSettings();
    notifyListeners();
  }

  void setAutoReconnect(bool v) {
    _autoReconnect = v;
    _saveSettings();
    notifyListeners();
  }

  // ── Ride History ──────────────────────────────────────────────────────────
  Future<void> _loadRideHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('rideHistory');
      if (raw != null) {
        final list = jsonDecode(raw) as List<dynamic>;
        _rideHistory =
            list.map((j) => RideRecord.fromJson(j as Map<String, dynamic>)).toList();
        _rideHistory.sort((a, b) => b.date.compareTo(a.date));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Load ride history error: $e');
    }
  }

  Future<void> _saveRideHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'rideHistory', jsonEncode(_rideHistory.map((r) => r.toJson()).toList()));
    } catch (e) {
      debugPrint('Save ride history error: $e');
    }
  }

  void _archiveTrip() {
    if (_totalDistance < 0.1) return;
    final record = RideRecord(
      date: DateTime.now(),
      distance: _totalDistance,
      duration: _tripDuration,
      maxSpeed: _maxSpeed,
      avgSpeed: avgSpeed,
    );
    _rideHistory.insert(0, record);
    if (_rideHistory.length > 50) _rideHistory.removeLast();
    _saveRideHistory();
  }

  // ── Maintenance ───────────────────────────────────────────────────────────
  void addMaintenanceEntry(String title, String desc, String category) {
    _maintenanceLogs.insert(
      0,
      MaintenanceEntry(
          title: title,
          description: desc,
          date: DateTime.now(),
          category: category),
    );
    notifyListeners();
  }

  // ── Weather ───────────────────────────────────────────────────────────────
  Future<void> fetchWeather(
      {double lat = 13.08, double lon = 80.27}) async {
    _isLoadingWeather = true;
    _weatherError = '';
    notifyListeners();
    try {
      final uri = Uri.parse(
          'https://api.open-meteo.com/v1/forecast'
          '?latitude=$lat&longitude=$lon'
          '&current_weather=true'
          '&daily=weathercode,temperature_2m_max,temperature_2m_min,windspeed_10m_max'
          '&timezone=auto&forecast_days=5');
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        _weatherData = jsonDecode(res.body) as Map<String, dynamic>;
      } else {
        _weatherError = 'Server error ${res.statusCode}';
      }
    } catch (e) {
      _weatherError = 'Network error — check connection';
    }
    _isLoadingWeather = false;
    notifyListeners();
  }

  // ── Native Bridge ─────────────────────────────────────────────────────────
  void _initNativeBridge() {
    platform.setMethodCallHandler((call) async {
      if (call.method == 'onMusicUpdate' && !_isPlayingLocal) {
        _currentSong = call.arguments['title'] ?? 'Unknown Title';
        _currentArtist = call.arguments['artist'] ?? 'Unknown Artist';
        notifyListeners();
        _sendToTripper('$_currentSong - $_currentArtist');
      }
    });
  }

  // ── Local Music ───────────────────────────────────────────────────────────
  Future<void> _scanLocalMusic() async {
    try {
      if (!await _audioQuery.permissionsStatus()) {
        await _audioQuery.permissionsRequest();
      }
      _localSongs = await _audioQuery.querySongs(
        sortType: null,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Music scan error: $e');
    }
  }

  Future<void> playLocalSong(SongModel song) async {
    _isPlayingLocal = true;
    _currentSong = song.title;
    _currentArtist = song.artist ?? 'Unknown Artist';
    await _audioPlayer.play(DeviceFileSource(song.data));
    _sendToTripper('$_currentSong - $_currentArtist');
    notifyListeners();
  }

  Future<void> stopLocalMusic() async {
    await _audioPlayer.stop();
    _isPlayingLocal = false;
    notifyListeners();
  }

  // ── Location / Trip ───────────────────────────────────────────────────────
  void _initLocationTracking() {
    try {
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high, distanceFilter: 5),
      ).listen((pos) {
        if (!_isTracking) return;
        _currentSpeed = pos.speed * 3.6;
        if (_currentSpeed > _maxSpeed) _maxSpeed = _currentSpeed;
        _totalSpeedSum += _currentSpeed;
        _speedSamples++;
        _speedHistory.add(_currentSpeed);
        if (_speedHistory.length > 60) _speedHistory.removeAt(0);
        if (_lastPosition != null) {
          _totalDistance += Geolocator.distanceBetween(
                _lastPosition!.latitude,
                _lastPosition!.longitude,
                pos.latitude,
                pos.longitude,
              ) /
              1000;
        }
        _lastPosition = pos;
        notifyListeners();
        _sendDistanceToTripper(_currentSpeed.toInt());
      });
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  void startTrip() {
    _isTracking = true;
    _maxSpeed = 0;
    _totalDistance = 0;
    _totalSpeedSum = 0;
    _speedSamples = 0;
    _tripDuration = Duration.zero;
    _speedHistory.clear();
    _tripTimer?.cancel();
    _tripTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tripDuration += const Duration(seconds: 1);
      notifyListeners();
    });
    notifyListeners();
  }

  void stopTrip() {
    _isTracking = false;
    _tripTimer?.cancel();
    _archiveTrip();
    notifyListeners();
  }

  // ── BLE ───────────────────────────────────────────────────────────────────
  Future<void> startScan() async {
    _isScanning = true;
    _scanResults = [];
    notifyListeners();
    try {
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
      FlutterBluePlus.scanResults.listen((results) {
        _scanResults = results
            .where((r) => r.device.platformName.isNotEmpty)
            .toList();
        notifyListeners();
      });
      await Future.delayed(const Duration(seconds: 15));
    } catch (e) {
      debugPrint('Scan error: $e');
    }
    _isScanning = false;
    notifyListeners();
  }

  Future<void> connect(BluetoothDevice device) async {
    try {
      await device.connect(autoConnect: _autoReconnect);
      _connectedDevice = device;
      final services = await device.discoverServices();
      for (final s in services) {
        if (s.uuid.toString().contains('fee7')) {
          for (final c in s.characteristics) {
            if (c.properties.write) _writeCharacteristic = c;
          }
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Connect error: $e');
    }
  }

  Future<void> _sendToTripper(String text) async {
    if (_writeCharacteristic == null) return;
    final bytes = utf8.encode(text);
    final len = bytes.length + 1;
    await _writeCharacteristic!.write(
        [0x01, (len >> 8) & 0xFF, len & 0xFF, ...bytes, 0x00],
        withoutResponse: true);
  }

  Future<void> _sendDistanceToTripper(int kmh) async {
    if (_writeCharacteristic == null) return;
    await _writeCharacteristic!.write(
        [0x04, 0x00, 0x02, (kmh >> 8) & 0xFF, kmh & 0xFF],
        withoutResponse: true);
  }
}
