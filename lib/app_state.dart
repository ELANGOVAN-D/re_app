import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class AppState extends ChangeNotifier {
  static const platform = MethodChannel('com.example.re_app/tripper');
  
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  bool _isScanning = false;
  List<ScanResult> _scanResults = [];
  
  // Media State
  String _currentSong = "No music playing";
  String _currentArtist = "";
  
  // Ride Stats
  double _currentSpeed = 0.0;
  double _maxSpeed = 0.0;
  double _totalDistance = 0.0;
  Duration _tripDuration = Duration.zero;
  bool _isTracking = false;
  Position? _lastPosition;
  Timer? _tripTimer;

  // Getters
  BluetoothDevice? get connectedDevice => _connectedDevice;
  bool get isScanning => _isScanning;
  List<ScanResult> get scanResults => _scanResults;
  String get currentSong => _currentSong;
  String get currentArtist => _currentArtist;
  double get currentSpeed => _currentSpeed;
  double get maxSpeed => _maxSpeed;
  double get totalDistance => _totalDistance;
  Duration get tripDuration => _tripDuration;
  bool get isTracking => _isTracking;

  AppState() {
    _initNativeBridge();
    _initLocationTracking();
  }

  void _initNativeBridge() {
    platform.setMethodCallHandler((call) async {
      if (call.method == "onMusicUpdate") {
        _currentSong = call.arguments['title'] ?? "Unknown Title";
        _currentArtist = call.arguments['artist'] ?? "Unknown Artist";
        notifyListeners();
        _sendToTripper("${_currentSong} - ${_currentArtist}");
      }
    });
  }

  void _initLocationTracking() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5),
    ).listen((Position position) {
      if (!_isTracking) return;
      
      _currentSpeed = position.speed * 3.6; // m/s to km/h
      if (_currentSpeed > _maxSpeed) _maxSpeed = _currentSpeed;
      
      if (_lastPosition != null) {
        _totalDistance += Geolocator.distanceBetween(
          _lastPosition!.latitude, _lastPosition!.longitude,
          position.latitude, position.longitude
        ) / 1000;
      }
      _lastPosition = position;
      notifyListeners();
      
      // Send speed to Tripper Distance field for fun
      _sendDistanceToTripper(_currentSpeed.toInt());
    });
  }

  void startTrip() {
    _isTracking = true;
    _maxSpeed = 0.0;
    _totalDistance = 0.0;
    _tripDuration = Duration.zero;
    _tripTimer?.cancel();
    _tripTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _tripDuration += const Duration(seconds: 1);
      notifyListeners();
    });
    notifyListeners();
  }

  void stopTrip() {
    _isTracking = false;
    _tripTimer?.cancel();
    notifyListeners();
  }

  Future<void> startScan() async {
    _isScanning = true;
    _scanResults = [];
    notifyListeners();

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results.where((r) => r.device.name.isNotEmpty).toList();
      notifyListeners();
    });

    await Future.delayed(const Duration(seconds: 15));
    _isScanning = false;
    notifyListeners();
  }

  Future<void> connect(BluetoothDevice device) async {
    await device.connect(autoConnect: true);
    _connectedDevice = device;
    
    List<BluetoothService> services = await device.discoverServices();
    for (var service in services) {
      if (service.uuid.toString().contains("fee7")) {
        for (var char in service.characteristics) {
          if (char.properties.write) _writeCharacteristic = char;
        }
      }
    }
    notifyListeners();
  }

  Future<void> _sendToTripper(String text) async {
    if (_writeCharacteristic == null) return;
    List<int> bytes = utf8.encode(text);
    int len = bytes.length + 1;
    List<int> packet = [0x01, (len >> 8) & 0xFF, len & 0xFF, ...bytes, 0x00];
    await _writeCharacteristic!.write(packet, withoutResponse: true);
  }

  Future<void> _sendDistanceToTripper(int kmh) async {
    if (_writeCharacteristic == null) return;
    // Using Distance TLV 0x04
    List<int> packet = [0x04, 0x00, 0x02, (kmh >> 8) & 0xFF, kmh & 0xFF];
    await _writeCharacteristic!.write(packet, withoutResponse: true);
  }
}
