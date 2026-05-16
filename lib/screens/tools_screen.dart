import 'package:flutter/material.dart';
import '../tools/local_music_screen.dart';
import '../tools/fuel_calculator_screen.dart';
import '../tools/weather_screen.dart';
import '../tools/ride_history_screen.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RIDER TOOLS PRO',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(20),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _ToolCard(
            icon: Icons.music_note_rounded,
            label: 'Local Music',
            subtitle: 'Play device songs',
            color: Colors.pinkAccent,
            target: const LocalMusicScreen(),
          ),
          _ToolCard(
            icon: Icons.local_gas_station_rounded,
            label: 'Fuel Calc',
            subtitle: 'Range & cost planner',
            color: Colors.orange,
            target: const FuelCalculatorScreen(),
          ),
          _ToolCard(
            icon: Icons.cloud_rounded,
            label: 'Weather Pro',
            subtitle: '5-day forecast',
            color: Colors.blueAccent,
            target: const WeatherScreen(),
          ),
          _ToolCard(
            icon: Icons.history_rounded,
            label: 'Ride History',
            subtitle: 'Past trips & stats',
            color: Colors.greenAccent,
            target: const RideHistoryScreen(),
          ),
          _ToolCard(
            icon: Icons.group_rounded,
            label: 'RE Community',
            subtitle: 'Clubs & rides',
            color: Colors.purple,
            onTapMsg: 'Community Feature — Coming Soon!',
          ),
          _ToolCard(
            icon: Icons.build_rounded,
            label: 'Diagnostics',
            subtitle: 'OBD-II bridge',
            color: Colors.tealAccent,
            onTapMsg: 'OBD Diagnostics — Coming Soon!',
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String label, subtitle;
  final Color color;
  final Widget? target;
  final String? onTapMsg;

  const _ToolCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    this.target,
    this.onTapMsg,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (target != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => target!));
        } else if (onTapMsg != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(onTapMsg!)));
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.18)),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.05), blurRadius: 12, spreadRadius: 1)
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 14),
            Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(fontSize: 11, color: Colors.white38),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
