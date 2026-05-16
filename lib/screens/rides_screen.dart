import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../app_state.dart';
import '../widgets/speedometer_gauge.dart';
import '../widgets/glass_card.dart';

class RidesScreen extends StatelessWidget {
  const RidesScreen({super.key});

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('LIVE TELEMETRY',
                        style: TextStyle(
                            letterSpacing: 3,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ),
                  if (state.isTracking)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(width: 6, height: 6,
                            decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        const Text('LIVE', style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              Center(child: SpeedometerGauge(speed: state.currentSpeed)),
              const SizedBox(height: 32),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.2,
                children: [
                  _StatCard(label: 'MAX SPEED', value: '${state.maxSpeed.toInt()}', unit: 'km/h', icon: Icons.arrow_upward, color: Colors.redAccent),
                  _StatCard(label: 'DISTANCE', value: state.totalDistance.toStringAsFixed(2), unit: 'km', icon: Icons.straighten, color: Colors.blueAccent),
                  _StatCard(label: 'AVG SPEED', value: '${state.avgSpeed.toInt()}', unit: 'km/h', icon: Icons.speed, color: Colors.amber),
                  _StatCard(label: 'DURATION', value: _fmt(state.tripDuration), unit: 'elapsed', icon: Icons.timer, color: Colors.greenAccent),
                ],
              ),
              const SizedBox(height: 24),
              if (state.speedHistory.isNotEmpty) ...[
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SPEED HISTORY', style: TextStyle(fontSize: 10, letterSpacing: 2, color: Colors.white.withOpacity(0.4))),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 100,
                        child: LineChart(LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineTouchData: const LineTouchData(enabled: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: state.speedHistory.asMap().entries
                                  .map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                              isCurved: true,
                              color: const Color(0xFFFF3B30),
                              barWidth: 2.5,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(show: true, color: const Color(0xFFFF3B30).withOpacity(0.1)),
                            ),
                          ],
                        )),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: state.isTracking ? state.stopTrip : state.startTrip,
                  icon: Icon(state.isTracking ? Icons.stop_circle_outlined : Icons.play_arrow),
                  label: Text(state.isTracking ? 'END TRIP' : 'START TRIP',
                      style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: state.isTracking ? Colors.white10 : const Color(0xFFFF3B30),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, unit;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.unit, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderColor: color.withOpacity(0.15),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.4), letterSpacing: 1)),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              Text(unit, style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.4))),
            ],
          ),
        ],
      ),
    );
  }
}
