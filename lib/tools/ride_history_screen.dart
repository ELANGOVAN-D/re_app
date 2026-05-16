import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../app_state.dart';
import '../widgets/glass_card.dart';

class RideHistoryScreen extends StatelessWidget {
  const RideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final history = state.rideHistory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('RIDE HISTORY',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
      ),
      body: history.isEmpty
          ? const _EmptyState()
          : Column(
              children: [
                _SummaryBar(history: history),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: history.length,
                    itemBuilder: (ctx, i) => _RideCard(ride: history[i]),
                  ),
                ),
              ],
            ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  final List<RideRecord> history;
  const _SummaryBar({required this.history});

  @override
  Widget build(BuildContext context) {
    final totalKm =
        history.fold(0.0, (s, r) => s + r.distance);
    final bestSpeed =
        history.fold(0.0, (s, r) => r.maxSpeed > s ? r.maxSpeed : s);
    final totalSec =
        history.fold(0, (s, r) => s + r.duration.inSeconds);
    final totalDur = Duration(seconds: totalSec);

    return Container(
      margin: const EdgeInsets.all(16),
      child: GlassCard(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _SumStat(
                label: 'TOTAL RIDES',
                value: '${history.length}',
                color: Colors.blueAccent),
            _vDiv(),
            _SumStat(
                label: 'TOTAL KM',
                value: totalKm.toStringAsFixed(1),
                color: Colors.greenAccent),
            _vDiv(),
            _SumStat(
                label: 'BEST SPEED',
                value: '${bestSpeed.toInt()}',
                unit: 'km/h',
                color: Colors.redAccent),
            _vDiv(),
            _SumStat(
                label: 'RIDE TIME',
                value: _fmtDur(totalDur),
                color: Colors.amber),
          ],
        ),
      ),
    );
  }

  Widget _vDiv() =>
      Container(width: 1, height: 36, color: Colors.white.withOpacity(0.08));

  String _fmtDur(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }
}

class _SumStat extends StatelessWidget {
  final String label, value;
  final String? unit;
  final Color color;
  const _SumStat(
      {required this.label,
      required this.value,
      this.unit,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(label,
          style: const TextStyle(
              fontSize: 8, color: Colors.white38, letterSpacing: 1.2)),
      const SizedBox(height: 4),
      Text(value,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w900, color: color)),
      if (unit != null)
        Text(unit!,
            style: const TextStyle(fontSize: 9, color: Colors.white38)),
    ]);
  }
}

class _RideCard extends StatelessWidget {
  final RideRecord ride;
  const _RideCard({required this.ride});

  String _fmtDur(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '${h}h ${m}m' : '${d.inMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFF3B30).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.motorcycle_rounded,
                color: Color(0xFFFF3B30), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEE, dd MMM yyyy').format(ride.date),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    DateFormat('hh:mm a').format(ride.date),
                    style: const TextStyle(
                        fontSize: 11, color: Colors.white38),
                  ),
                ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(
              '${ride.distance.toStringAsFixed(2)} km',
              style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: Color(0xFFFF3B30)),
            ),
            Text(_fmtDur(ride.duration),
                style: const TextStyle(
                    fontSize: 11, color: Colors.white38)),
          ]),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Mini(
                    label: 'MAX',
                    value: '${ride.maxSpeed.toInt()} km/h',
                    color: Colors.redAccent),
                _Mini(
                    label: 'AVG',
                    value: '${ride.avgSpeed.toInt()} km/h',
                    color: Colors.amber),
              ]),
        ),
      ]),
    );
  }
}

class _Mini extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Mini(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(label,
          style: const TextStyle(
              fontSize: 9, color: Colors.white38, letterSpacing: 1)),
      const SizedBox(height: 2),
      Text(value,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 14, color: color)),
    ]);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('🏍️', style: TextStyle(fontSize: 64)),
        SizedBox(height: 16),
        Text('No rides recorded yet',
            style: TextStyle(fontSize: 18, color: Colors.white54)),
        SizedBox(height: 8),
        Text('Start a trip from the Rides tab',
            style: TextStyle(fontSize: 12, color: Colors.white24)),
      ]),
    );
  }
}
