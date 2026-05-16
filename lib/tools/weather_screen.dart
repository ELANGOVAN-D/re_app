import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../widgets/glass_card.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  static const _wmoLabels = {
    0: 'Clear Sky', 1: 'Mainly Clear', 2: 'Partly Cloudy', 3: 'Overcast',
    45: 'Foggy', 48: 'Icy Fog',
    51: 'Light Drizzle', 53: 'Drizzle', 55: 'Heavy Drizzle',
    61: 'Light Rain', 63: 'Rain', 65: 'Heavy Rain',
    71: 'Light Snow', 73: 'Snow', 75: 'Heavy Snow',
    80: 'Showers', 81: 'Rain Showers', 82: 'Violent Showers',
    95: 'Thunderstorm', 96: 'Hail Storm', 99: 'Heavy Hail',
  };

  static const _wmoIcons = {
    0: '☀️', 1: '🌤️', 2: '⛅', 3: '☁️',
    45: '🌫️', 48: '🌫️',
    51: '🌦️', 53: '🌧️', 55: '🌧️',
    61: '🌧️', 63: '🌧️', 65: '🌧️',
    71: '🌨️', 73: '❄️', 75: '❄️',
    80: '🌦️', 81: '🌧️', 82: '⛈️',
    95: '⛈️', 96: '⛈️', 99: '⛈️',
  };

  String _icon(int code) => _wmoIcons[code] ?? '🌡️';
  String _label(int code) => _wmoLabels[code] ?? 'Unknown';

  String _riderAdvice(int code) {
    if (code == 0 || code == 1) return '🏍️ Perfect riding conditions! Hit the road.';
    if (code <= 3) return '😊 Good to ride — light clouds, no rain.';
    if (code <= 48) return '⚠️ Foggy conditions — ride with low beam on.';
    if (code <= 67) return '🌧️ Rain detected — avoid riding if possible.';
    if (code <= 77) return '❄️ Snow/ice — do NOT ride.';
    return '⛈️ Severe weather — stay safe, don\'t ride.';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('WEATHER PRO',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
        actions: [
          IconButton(
            onPressed: state.fetchWeather,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: state.isLoadingWeather
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF3B30)))
          : state.weatherError.isNotEmpty || state.weatherData == null
              ? _ErrorState(error: state.weatherError, onRetry: state.fetchWeather)
              : _WeatherContent(
                  data: state.weatherData!,
                  icon: _icon,
                  label: _label,
                  advice: _riderAdvice,
                ),
    );
  }
}

class _WeatherContent extends StatelessWidget {
  final Map<String, dynamic> data;
  final String Function(int) icon;
  final String Function(int) label;
  final String Function(int) advice;

  const _WeatherContent({
    required this.data, required this.icon,
    required this.label, required this.advice,
  });

  @override
  Widget build(BuildContext context) {
    final cw = data['current_weather'] as Map<String, dynamic>;
    final temp = (cw['temperature'] as num).toDouble();
    final wind = (cw['windspeed'] as num).toDouble();
    final code = (cw['weathercode'] as num).toInt();
    final daily = data['daily'] as Map<String, dynamic>;
    final dates = (daily['time'] as List).cast<String>();
    final maxTemps = (daily['temperature_2m_max'] as List).cast<num>();
    final minTemps = (daily['temperature_2m_min'] as List).cast<num>();
    final winds = (daily['windspeed_10m_max'] as List).cast<num>();
    final codes = (daily['weathercode'] as List).cast<num>();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Current weather hero
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF0A1A2A), const Color(0xFF050505)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
          ),
          child: Column(children: [
            Text(icon(code), style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 8),
            Text('${temp.toStringAsFixed(1)}°C',
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900)),
            Text(label(code), style: const TextStyle(fontSize: 16, color: Colors.white60)),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _CWStat(icon: '💨', label: 'Wind', value: '${wind.toInt()} km/h'),
              _CWStat(icon: '🌡️', label: 'Feels Like', value: '${temp.toStringAsFixed(0)}°C'),
            ]),
          ]),
        ),
        const SizedBox(height: 16),
        // Rider advice
        GlassCard(
          borderColor: Colors.amberAccent.withOpacity(0.2),
          child: Row(children: [
            const Text('🏍️', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(child: Text(advice(code),
                style: const TextStyle(fontSize: 14, height: 1.5))),
          ]),
        ),
        const SizedBox(height: 16),
        Text('5-DAY FORECAST',
            style: TextStyle(fontSize: 11, letterSpacing: 2, color: Colors.white.withOpacity(0.4))),
        const SizedBox(height: 12),
        // Forecast cards
        ...List.generate(dates.length, (i) {
          final dt = DateTime.parse(dates[i]);
          final dayName = _dayName(dt, i);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(children: [
              SizedBox(width: 60, child: Text(dayName,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
              Text(icon(codes[i].toInt()), style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(child: Text(label(codes[i].toInt()),
                  style: const TextStyle(fontSize: 12, color: Colors.white54))),
              Text('${maxTemps[i].toInt()}° / ${minTemps[i].toInt()}°',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ]),
          );
        }),
        const SizedBox(height: 16),
        Center(
          child: Text('Powered by Open-Meteo',
              style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.2))),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  String _dayName(DateTime dt, int i) {
    if (i == 0) return 'Today';
    if (i == 1) return 'Tomorrow';
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[dt.weekday - 1];
  }
}

class _CWStat extends StatelessWidget {
  final String icon, label, value;
  const _CWStat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(icon, style: const TextStyle(fontSize: 20)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.white38)),
    ]);
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('⛈️', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 16),
        Text(error.isNotEmpty ? error : 'Weather unavailable',
            style: const TextStyle(color: Colors.white54), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('TRY AGAIN'),
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF3B30)),
        ),
      ]),
    );
  }
}
