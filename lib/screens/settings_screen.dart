import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../widgets/glass_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionLabel('APPEARANCE'),
          const SizedBox(height: 10),
          GlassCard(
            child: Column(children: [
              _ToggleTile(
                icon: Icons.dark_mode_rounded,
                label: 'Dark Mode',
                subtitle: 'Stealth black interface',
                value: state.isDarkMode,
                color: Colors.blueAccent,
                onChanged: state.setDarkMode,
              ),
              const Divider(color: Colors.white10, height: 1),
              _ToggleTile(
                icon: Icons.straighten_rounded,
                label: 'Metric Units',
                subtitle: 'Use km, litres, Celsius',
                value: state.useMetricUnits,
                color: Colors.greenAccent,
                onChanged: state.setMetricUnits,
              ),
            ]),
          ),
          const SizedBox(height: 20),
          _sectionLabel('CONNECTIVITY'),
          const SizedBox(height: 10),
          GlassCard(
            child: Column(children: [
              _ToggleTile(
                icon: Icons.bluetooth_rounded,
                label: 'Auto-Reconnect',
                subtitle: 'Reconnect to last device automatically',
                value: state.autoReconnect,
                color: const Color(0xFFFF3B30),
                onChanged: state.setAutoReconnect,
              ),
            ]),
          ),
          const SizedBox(height: 20),
          _sectionLabel('FEEDBACK'),
          const SizedBox(height: 10),
          GlassCard(
            child: _ToggleTile(
              icon: Icons.vibration_rounded,
              label: 'Haptic Feedback',
              subtitle: 'Vibrate on actions',
              value: state.hapticEnabled,
              color: Colors.amber,
              onChanged: state.setHaptic,
            ),
          ),
          const SizedBox(height: 20),
          _sectionLabel('ABOUT'),
          const SizedBox(height: 10),
          GlassCard(
            child: Column(children: [
              const _InfoTile(icon: Icons.info_outline, label: 'App Version', value: '1.1.0'),
              const Divider(color: Colors.white10, height: 1),
              const _InfoTile(icon: Icons.motorcycle_rounded, label: 'Device', value: 'Classic 350 — 2023'),
              const Divider(color: Colors.white10, height: 1),
              const _InfoTile(icon: Icons.developer_board_rounded, label: 'BLE Protocol', value: 'Tripper v2.1'),
              const Divider(color: Colors.white10, height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.open_in_new, color: Colors.redAccent, size: 18),
                ),
                title: const Text('Royal Enfield Website',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: const Text('www.royalenfield.com',
                    style: TextStyle(fontSize: 11, color: Colors.white38)),
                trailing: const Icon(Icons.chevron_right, color: Colors.white24),
                onTap: () {},
              ),
            ]),
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'STEALTH BRIDGE PRO',
              style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 3,
                  color: Colors.white.withValues(alpha: 0.2),
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Built for RE Tripper Pod',
              style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.15)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(text,
            style: TextStyle(
                fontSize: 10,
                letterSpacing: 2,
                color: Colors.white.withValues(alpha: 0.35),
                fontWeight: FontWeight.bold)),
      );
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label, subtitle;
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.white38)),
      trailing: Switch(value: value, onChanged: onChanged, activeColor: color),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white54, size: 18),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      trailing: Text(value, style: const TextStyle(color: Colors.white38, fontSize: 13)),
    );
  }
}
