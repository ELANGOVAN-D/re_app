import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_state.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RE STEALTH BRIDGE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050505),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.redAccent,
          brightness: Brightness.dark,
          primary: Colors.redAccent,
          secondary: Colors.amberAccent,
          surface: const Color(0xFF121212),
        ),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const DashboardScreen(),
    const RidesScreen(),
    const TripPlannerScreen(), // NEW
    const ToolsScreen(),
    const GarageScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
      Permission.phone,
      Permission.notification,
    ].request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        backgroundColor: const Color(0xFF0D0D0D),
        indicatorColor: Colors.redAccent.withOpacity(0.2),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'DASH'),
          NavigationDestination(icon: Icon(Icons.speed_rounded), label: 'RIDES'),
          NavigationDestination(icon: Icon(Icons.route_rounded), label: 'PLANNER'),
          NavigationDestination(icon: Icon(Icons.build_circle_rounded), label: 'TOOLS'),
          NavigationDestination(icon: Icon(Icons.motorcycle_rounded), label: 'GARAGE'),
        ],
      ),
    );
  }
}

// --- SCREEN 1: DASHBOARD ---
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: Text('STEALTH BRIDGE', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 2)),
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined)),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildSearchBar(context),
                const SizedBox(height: 20),
                _buildStatusCard(state),
                const SizedBox(height: 20),
                _buildMusicPlayer(state),
                const SizedBox(height: 20),
                _buildQuickActions(context),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildStatusCard(AppState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: state.connectedDevice != null ? Colors.green : Colors.redAccent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          _PulseIcon(isActive: state.connectedDevice != null),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CONNECTION STATUS', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.4), letterSpacing: 1)),
                Text(state.connectedDevice != null ? 'CONNECTED TO TRIPPER' : 'TRIPPER NOT FOUND', 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          if (state.connectedDevice == null)
            IconButton.filledTonal(
              onPressed: () => state.startScan(),
              icon: Icon(state.isScanning ? Icons.sync : Icons.search),
            )
        ],
      ),
    );
  }

  Widget _buildMusicPlayer(AppState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFF1E1E1E), const Color(0xFF0F0F0F)]),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.music_note_rounded, color: Colors.redAccent),
              const SizedBox(width: 8),
              const Text('NOW PLAYING', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const Spacer(),
              Text('STREAMING', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          Text(state.currentSong, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900), maxLines: 1),
          Text(state.currentArtist, style: TextStyle(color: Colors.white.withOpacity(0.5))),
          const SizedBox(height: 24),
          const LinearProgressIndicator(value: 0.3, backgroundColor: Colors.white10, valueColor: AlwaysStoppedAnimation(Colors.redAccent)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Where to, Rider?',
          prefixIcon: const Icon(Icons.search, color: Colors.redAccent),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
        onSubmitted: (val) {
          // Logic for Search
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Finding route to: $val...'))
          );
        },
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _QuickActionBtn(
          icon: Icons.sos_rounded, 
          label: 'SOS', 
          color: Colors.red,
          onTap: () => _handleSOS(context),
        )),
        const SizedBox(width: 15),
        Expanded(child: _QuickActionBtn(
          icon: Icons.map_rounded, 
          label: 'NEARBY', 
          color: Colors.blue,
          onTap: () => _launchNearby(context),
        )),
        const SizedBox(width: 15),
        Expanded(child: _QuickActionBtn(
          icon: Icons.lightbulb_rounded, 
          label: 'THEME', 
          color: Colors.amber,
          onTap: () => _toggleTheme(context),
        )),
      ],
    );
  }

  void _handleSOS(BuildContext context) async {
    final Uri url = Uri.parse('tel:112');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch SOS call')));
    }
  }

  void _launchNearby(BuildContext context) async {
    const url = 'https://www.google.com/maps/search/?api=1&query=petrol+pump+near+me';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _toggleTheme(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Theme Customization Active: Stealth Black Mode'))
    );
  }
}

// --- SCREEN 2: RIDE STATS ---
class RidesScreen extends StatelessWidget {
  const RidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Text('LIVE TELEMETRY', style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              _buildSpeedometer(state),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(label: 'MAX SPEED', value: '${state.maxSpeed.toStringAsFixed(1)} km/h'),
                  _StatItem(label: 'DISTANCE', value: '${state.totalDistance.toStringAsFixed(2)} km'),
                ],
              ),
              const SizedBox(height: 40),
              Expanded(child: _buildRideChart()),
              const SizedBox(height: 20),
              _buildTripControls(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedometer(AppState state) {
    return Column(
      children: [
        Text(state.currentSpeed.toInt().toString(), style: GoogleFonts.outfit(fontSize: 100, fontWeight: FontWeight.w900, color: Colors.white)),
        const Text('KM/H', style: TextStyle(letterSpacing: 4, color: Colors.redAccent, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildRideChart() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [const FlSpot(0, 0), const FlSpot(1, 20), const FlSpot(2, 45), const FlSpot(3, 40), const FlSpot(4, 60)],
            isCurved: true,
            color: Colors.redAccent,
            barWidth: 4,
            belowBarData: BarAreaData(show: true, color: Colors.redAccent.withOpacity(0.1)),
          )
        ]
      )
    );
  }

  Widget _buildTripControls(AppState state) {
    return ElevatedButton(
      onPressed: state.isTracking ? () => state.stopTrip() : () => state.startTrip(),
      style: ElevatedButton.styleFrom(
        backgroundColor: state.isTracking ? Colors.white10 : Colors.redAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      ),
      child: Text(state.isTracking ? 'PAUSE TRIP' : 'START NEW TRIP'),
    );
  }
}

// --- SCREEN 3: TRIP PLANNER ---
class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({super.key});

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  bool _isScenic = true;
  final List<String> _stops = ['Home', 'Mount Road'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TRIP PLANNER', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildScenicToggle(),
            const SizedBox(height: 20),
            Expanded(child: _buildStopsList()),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildScenicToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF121212), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const Icon(Icons.terrain, color: Colors.green),
          const SizedBox(width: 12),
          const Expanded(child: Text('SCENIC ROUTE MODE', style: TextStyle(fontWeight: FontWeight.bold))),
          Switch(value: _isScenic, onChanged: (v) => setState(() => _isScenic = v), activeColor: Colors.green),
        ],
      ),
    );
  }

  Widget _buildStopsList() {
    return ListView.builder(
      itemCount: _stops.length,
      itemBuilder: (context, i) => ListTile(
        leading: Icon(i == 0 ? Icons.my_location : Icons.location_on, color: i == 0 ? Colors.blue : Colors.redAccent),
        title: Text(_stops[i]),
        trailing: const Icon(Icons.drag_handle),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add_location_alt),
          label: const Text('ADD STOP'),
          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 60),
          ),
          child: const Text('SYNC TO TRIPPER POD', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

// --- SCREEN 3: TOOLS ---
class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 40),
        const Text('RIDER TOOLS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _buildToolTile(Icons.cloud_outlined, 'Weather Forecast', 'Current: 28°C - Clear Skies'),
        _buildToolTile(Icons.local_gas_station_rounded, 'Nearby Petrol', 'Closest: Shell (1.2 km)'),
        _buildToolTile(Icons.coffee_rounded, 'Rider Cafes', 'Explore popular stops nearby'),
        _buildToolTile(Icons.group_rounded, 'Group Ride', 'Create a live session with friends'),
      ],
    );
  }

  Widget _buildToolTile(IconData icon, String title, String sub) {
    return Card(
      color: const Color(0xFF121212),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: Colors.redAccent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(sub, style: const TextStyle(fontSize: 12, color: Colors.white54)),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

// --- SCREEN 4: GARAGE ---
class GarageScreen extends StatelessWidget {
  const GarageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text('MY GARAGE', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const Text('Classic 350 Stealth Black', style: TextStyle(color: Colors.redAccent)),
          const SizedBox(height: 30),
          _buildServiceProgress(),
          const SizedBox(height: 30),
          const Text('LOGS', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildLogItem('Fuel Refill', '2.5L @ ₹102.5', 'Yesterday'),
          _buildLogItem('Chain Clean', 'DIY Service', '3 Days Ago'),
        ],
      ),
    );
  }

  Widget _buildServiceProgress() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('Next Service'), Text('750 / 5000 km')],
          ),
          const SizedBox(height: 10),
          const LinearProgressIndicator(value: 0.15, backgroundColor: Colors.white10, valueColor: AlwaysStoppedAnimation(Colors.redAccent)),
        ],
      ),
    );
  }

  Widget _buildLogItem(String title, String sub, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: Colors.white10, child: Icon(Icons.history_rounded, size: 16)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title), Text(sub, style: const TextStyle(fontSize: 10, color: Colors.white54))]),
          const Spacer(),
          Text(date, style: const TextStyle(fontSize: 10, color: Colors.white38)),
        ],
      ),
    );
  }
}

// --- SHARED WIDGETS ---
class _PulseIcon extends StatelessWidget {
  final bool isActive;
  const _PulseIcon({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12, height: 12,
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.red,
        shape: BoxShape.circle,
        boxShadow: [
          if (isActive) BoxShadow(color: Colors.green.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)
        ],
      ),
    );
  }
}

class _QuickActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickActionBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: const Color(0xFF121212), borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white38, letterSpacing: 1.5)),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
