import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';

class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({super.key});

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  bool _isScenic = true;
  final List<String> _stops = ['Home', 'Mount Road', 'Marina Beach'];
  double _dist = 150;
  double _mileage = 35;
  double _fuelPrice = 103.5;

  double get _fuelNeeded => _dist / _mileage;
  double get _fuelCost => _fuelNeeded * _fuelPrice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TRIP PLANNER', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
        actions: [
          IconButton(
            onPressed: _syncToTripper,
            icon: const Icon(Icons.sync_rounded, color: Color(0xFFFF3B30)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildScenicToggle(),
          const SizedBox(height: 16),
          _buildStopsList(),
          const SizedBox(height: 16),
          _buildFuelEstimator(),
          const SizedBox(height: 16),
          _buildEtaCard(),
          const SizedBox(height: 24),
          _buildSyncButton(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildScenicToggle() {
    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.terrain, color: Colors.green, size: 20),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SCENIC ROUTE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
                Text('Prefer ghat roads & hills', style: TextStyle(fontSize: 11, color: Colors.white54)),
              ],
            ),
          ),
          Switch(value: _isScenic, onChanged: (v) => setState(() => _isScenic = v), activeThumbColor: Colors.green),
        ],
      ),
    );
  }

  Widget _buildStopsList() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('WAYPOINTS', style: TextStyle(fontSize: 11, letterSpacing: 2, color: Colors.white.withValues(alpha: 0.4))),
              const Spacer(),
              TextButton.icon(
                onPressed: _addStop,
                icon: const Icon(Icons.add, size: 16, color: Color(0xFFFF3B30)),
                label: const Text('ADD', style: TextStyle(color: Color(0xFFFF3B30), fontSize: 11, letterSpacing: 1)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(_stops.length, (i) => _StopTile(
            stop: _stops[i],
            index: i,
            total: _stops.length,
            onDelete: i > 0 ? () => setState(() => _stops.removeAt(i)) : null,
          )),
        ],
      ),
    );
  }

  Widget _buildFuelEstimator() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FUEL ESTIMATOR', style: TextStyle(fontSize: 11, letterSpacing: 2, color: Colors.white.withValues(alpha: 0.4))),
          const SizedBox(height: 16),
          _SliderRow(label: 'Distance', value: _dist, min: 10, max: 1000,
              display: '${_dist.toInt()} km',
              onChanged: (v) => setState(() => _dist = v)),
          _SliderRow(label: 'Mileage', value: _mileage, min: 10, max: 60,
              display: '${_mileage.toInt()} km/L',
              onChanged: (v) => setState(() => _mileage = v)),
          _SliderRow(label: 'Fuel Price', value: _fuelPrice, min: 80, max: 130,
              display: '₹${_fuelPrice.toStringAsFixed(1)}/L',
              onChanged: (v) => setState(() => _fuelPrice = v)),
          const Divider(color: Colors.white10, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _FuelResult(label: 'FUEL NEEDED', value: '${_fuelNeeded.toStringAsFixed(2)} L'),
              Container(width: 1, height: 40, color: Colors.white10),
              _FuelResult(label: 'TOTAL COST', value: '₹${_fuelCost.toStringAsFixed(0)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEtaCard() {
    final etaHours = _dist / 50; // avg 50 km/h
    final h = etaHours.floor();
    final m = ((etaHours - h) * 60).round();
    return GlassCard(
      borderColor: Colors.blueAccent.withValues(alpha: 0.2),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.access_time, color: Colors.blueAccent),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ESTIMATED TIME', style: TextStyle(fontSize: 10, letterSpacing: 1.5, color: Colors.white.withValues(alpha: 0.4))),
              const SizedBox(height: 4),
              Text(h > 0 ? '${h}h ${m}m' : '${m}m',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              Text('at 50 km/h avg • ${_stops.length} stops',
                  style: const TextStyle(fontSize: 11, color: Colors.white38)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSyncButton() {
    return ElevatedButton.icon(
      onPressed: _syncToTripper,
      icon: const Icon(Icons.navigation_rounded),
      label: const Text('SYNC TO TRIPPER POD', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF3B30),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 58),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _addStop() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Add Waypoint'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Location name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) setState(() => _stops.add(ctrl.text.trim()));
              Navigator.pop(context);
            },
            child: const Text('ADD'),
          ),
        ],
      ),
    );
  }

  void _syncToTripper() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Syncing ${_stops.length} stops to Tripper Pod...'),
        backgroundColor: const Color(0xFFFF3B30),
      ),
    );
  }
}

class _StopTile extends StatelessWidget {
  final String stop;
  final int index, total;
  final VoidCallback? onDelete;
  const _StopTile({required this.stop, required this.index, required this.total, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Column(
            children: [
              Icon(index == 0 ? Icons.my_location : index == total - 1 ? Icons.flag : Icons.circle,
                  color: index == 0 ? Colors.blueAccent : index == total - 1 ? Colors.greenAccent : Colors.white24,
                  size: index == 0 || index == total - 1 ? 20 : 8),
              if (index < total - 1)
                Container(width: 1, height: 20, color: Colors.white12, margin: const EdgeInsets.symmetric(vertical: 2)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(stop, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
          if (onDelete != null)
            IconButton(onPressed: onDelete, icon: const Icon(Icons.remove_circle_outline, color: Colors.white24, size: 18)),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label, display;
  final double value, min, max;
  final ValueChanged<double> onChanged;
  const _SliderRow({required this.label, required this.value, required this.min, required this.max, required this.display, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.white54))),
        Expanded(child: Slider(value: value, min: min, max: max, onChanged: onChanged, activeColor: const Color(0xFFFF3B30), inactiveColor: Colors.white12)),
        SizedBox(width: 70, child: Text(display, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
      ],
    );
  }
}

class _FuelResult extends StatelessWidget {
  final String label, value;
  const _FuelResult({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.white38, letterSpacing: 1.5)),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFFFF3B30))),
      ],
    );
  }
}
