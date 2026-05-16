import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../app_state.dart';
import '../widgets/glass_card.dart';

class GarageScreen extends StatelessWidget {
  const GarageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('MY GARAGE',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
        actions: [
          IconButton(
            onPressed: () => _showAddLog(context, state),
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFFFF3B30)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _BikeProfileCard(),
          const SizedBox(height: 16),
          _ServiceProgressCard(state: state),
          const SizedBox(height: 16),
          _LifetimeStatsCard(state: state),
          const SizedBox(height: 16),
          Text('MAINTENANCE LOGS',
              style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 2,
                  color: Colors.white.withValues(alpha: 0.4))),
          const SizedBox(height: 12),
          ...state.maintenanceLogs.map((e) => _LogCard(entry: e)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showAddLog(BuildContext ctx, AppState state) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String category = 'Service';
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(builder: (ctx2, ss) {
        return Padding(
          padding: EdgeInsets.only(
              left: 24, right: 24, top: 24,
              bottom: MediaQuery.of(ctx2).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ADD LOG ENTRY',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: category,
                decoration: _inputDeco('Category'),
                dropdownColor: const Color(0xFF1A1A1A),
                items: ['Service', 'Fuel', 'DIY', 'Repair', 'Other']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => ss(() => category = v ?? category),
              ),
              const SizedBox(height: 12),
              TextField(controller: titleCtrl, decoration: _inputDeco('Title (e.g. Oil Change)')),
              const SizedBox(height: 12),
              TextField(controller: descCtrl, decoration: _inputDeco('Details')),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (titleCtrl.text.trim().isNotEmpty) {
                      state.addMaintenanceEntry(titleCtrl.text.trim(), descCtrl.text.trim(), category);
                    }
                    Navigator.pop(ctx2);
                  },
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF3B30)),
                  child: const Text('SAVE LOG'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      );
}

class _BikeProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E0A0A), Color(0xFF0F0F0F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFFF3B30).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFF3B30).withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.motorcycle_rounded, color: Color(0xFFFF3B30), size: 32),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ROYAL ENFIELD',
                  style: TextStyle(fontSize: 11, color: Colors.white38, letterSpacing: 1.5)),
              Text('Classic 350',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              Text('Stealth Black  •  2023',
                  style: TextStyle(color: Color(0xFFFF3B30), fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServiceProgressCard extends StatelessWidget {
  final AppState state;
  const _ServiceProgressCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final progress = (state.serviceProgressKm / state.serviceIntervalKm).clamp(0.0, 1.0);
    final remaining = state.serviceIntervalKm - state.serviceProgressKm;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.build_circle_rounded, color: Color(0xFFFF3B30), size: 18),
              const SizedBox(width: 8),
              Text('NEXT SERVICE', style: TextStyle(fontSize: 11, letterSpacing: 2, color: Colors.white.withValues(alpha: 0.4))),
              const Spacer(),
              Text('${remaining.toInt()} km left',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber)),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation(
                  progress > 0.7 ? Colors.redAccent : const Color(0xFFFF3B30)),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${state.serviceProgressKm.toInt()} km',
                  style: const TextStyle(fontSize: 11, color: Colors.white38)),
              Text('/ ${state.serviceIntervalKm.toInt()} km',
                  style: const TextStyle(fontSize: 11, color: Colors.white38)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LifetimeStatsCard extends StatelessWidget {
  final AppState state;
  const _LifetimeStatsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final totalDist = state.rideHistory.fold(0.0, (s, r) => s + r.distance);
    final totalRides = state.rideHistory.length;
    return GlassCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _GStat(label: 'TOTAL RIDES', value: '$totalRides', color: Colors.blueAccent),
          Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.08)),
          _GStat(label: 'TOTAL KM', value: totalDist.toStringAsFixed(1), color: Colors.greenAccent),
          Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.08)),
          _GStat(label: 'LOGS', value: '${state.maintenanceLogs.length}', color: Colors.amber),
        ],
      ),
    );
  }
}

class _GStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _GStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(label, style: const TextStyle(fontSize: 9, color: Colors.white38, letterSpacing: 1)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
    ]);
  }
}

class _LogCard extends StatelessWidget {
  final MaintenanceEntry entry;
  const _LogCard({required this.entry});

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Fuel': return Colors.orange;
      case 'DIY': return Colors.greenAccent;
      case 'Repair': return Colors.redAccent;
      default: return Colors.blueAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(entry.category);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.history_rounded, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(entry.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              if (entry.description.isNotEmpty)
                Text(entry.description, style: const TextStyle(fontSize: 11, color: Colors.white54)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(entry.category, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 4),
            Text(DateFormat('dd MMM').format(entry.date),
                style: const TextStyle(fontSize: 10, color: Colors.white38)),
          ]),
        ],
      ),
    );
  }
}
