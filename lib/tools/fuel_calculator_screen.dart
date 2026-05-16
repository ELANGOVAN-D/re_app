import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';

class FuelCalculatorScreen extends StatefulWidget {
  const FuelCalculatorScreen({super.key});

  @override
  State<FuelCalculatorScreen> createState() => _FuelCalculatorScreenState();
}

class _FuelCalculatorScreenState extends State<FuelCalculatorScreen> {
  double _dist = 200;
  double _mileage = 35;
  double _price = 103.5;
  double _tank = 13.0;

  double get _fuelNeeded => _dist / _mileage;
  double get _totalCost => _fuelNeeded * _price;
  int get _stops => (_fuelNeeded / _tank).ceil();
  double get _range => _mileage * _tank;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FUEL CALCULATOR',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GlassCard(
            child: Column(
              children: [
                _SliderTile(
                  icon: Icons.straighten, label: 'Trip Distance',
                  value: _dist, min: 10, max: 2000,
                  display: '${_dist.toInt()} km',
                  color: Colors.blueAccent,
                  onChanged: (v) => setState(() => _dist = v),
                ),
                const Divider(color: Colors.white10),
                _SliderTile(
                  icon: Icons.speed, label: 'Mileage',
                  value: _mileage, min: 10, max: 80,
                  display: '${_mileage.toInt()} km/L',
                  color: Colors.greenAccent,
                  onChanged: (v) => setState(() => _mileage = v),
                ),
                const Divider(color: Colors.white10),
                _SliderTile(
                  icon: Icons.currency_rupee, label: 'Fuel Price',
                  value: _price, min: 80, max: 140,
                  display: '₹${_price.toStringAsFixed(1)}/L',
                  color: Colors.amber,
                  onChanged: (v) => setState(() => _price = v),
                ),
                const Divider(color: Colors.white10),
                _SliderTile(
                  icon: Icons.local_gas_station, label: 'Tank Capacity',
                  value: _tank, min: 5, max: 25,
                  display: '${_tank.toInt()} L',
                  color: Colors.orange,
                  onChanged: (v) => setState(() => _tank = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.6,
            children: [
              _ResultCard(label: 'FUEL NEEDED', value: '${_fuelNeeded.toStringAsFixed(2)} L', icon: Icons.water_drop, color: Colors.blueAccent),
              _ResultCard(label: 'TOTAL COST', value: '₹${_totalCost.toStringAsFixed(0)}', icon: Icons.currency_rupee, color: Colors.amber),
              _ResultCard(label: 'FUEL STOPS', value: '$_stops stops', icon: Icons.local_gas_station, color: Colors.orange),
              _ResultCard(label: 'TANK RANGE', value: '${_range.toInt()} km', icon: Icons.map, color: Colors.greenAccent),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFF3B30).withOpacity(0.07),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFF3B30).withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Color(0xFFFF3B30), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _stops > 1
                        ? 'You\'ll need $_stops fuel stop${_stops > 1 ? 's' : ''} for this trip. Plan stops every ${(_dist / _stops).toInt()} km.'
                        : 'Your tank holds enough for this entire trip! ',
                    style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  final IconData icon;
  final String label, display;
  final double value, min, max;
  final Color color;
  final ValueChanged<double> onChanged;

  const _SliderTile({
    required this.icon, required this.label, required this.display,
    required this.value, required this.min, required this.max,
    required this.color, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 13, color: Colors.white70)),
            const Spacer(),
            Text(display, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        Slider(
          value: value, min: min, max: max, onChanged: onChanged,
          activeColor: color, inactiveColor: Colors.white10,
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _ResultCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderColor: color.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 9, color: Colors.white38, letterSpacing: 1)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }
}
