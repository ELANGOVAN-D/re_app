import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'app_state.dart';
import 'screens/dashboard_screen.dart';
import 'screens/rides_screen.dart';
import 'screens/trip_planner_screen.dart';
import 'screens/tools_screen.dart';
import 'screens/garage_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
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
    final state = context.watch<AppState>();
    return MaterialApp(
      title: 'STEALTH BRIDGE PRO',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(isDark: state.isDarkMode),
      home: const MainNavigation(),
    );
  }

  ThemeData _buildTheme({required bool isDark}) {
    const primary = Color(0xFFFF3B30);
    const secondary = Color(0xFFFF9F0A);

    if (isDark) {
      return ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050505),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: secondary,
          surface: Color(0xFF121212),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF0D0D0D),
          indicatorColor: primary.withValues(alpha: 0.15),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
        useMaterial3: true,
      );
    } else {
      return ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF2F2F7),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
        colorScheme: const ColorScheme.light(
          primary: primary,
          secondary: secondary,
          surface: Colors.white,
        ),
        useMaterial3: true,
      );
    }
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  static const _screens = <Widget>[
    DashboardScreen(),
    RidesScreen(),
    TripPlannerScreen(),
    ToolsScreen(),
    GarageScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    try {
      await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
        Permission.phone,
        Permission.notification,
        Permission.storage,
      ].request();
    } catch (e) {
      debugPrint('Permission request failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: _NavBar(
        selectedIndex: _selectedIndex,
        onChanged: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  const _NavBar({required this.selectedIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onChanged,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'DASH',
          ),
          NavigationDestination(
            icon: Icon(Icons.speed_outlined),
            selectedIcon: Icon(Icons.speed_rounded),
            label: 'RIDES',
          ),
          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            selectedIcon: Icon(Icons.route_rounded),
            label: 'PLAN',
          ),
          NavigationDestination(
            icon: Icon(Icons.build_circle_outlined),
            selectedIcon: Icon(Icons.build_circle_rounded),
            label: 'TOOLS',
          ),
          NavigationDestination(
            icon: Icon(Icons.motorcycle_outlined),
            selectedIcon: Icon(Icons.motorcycle_rounded),
            label: 'GARAGE',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'SETTINGS',
          ),
        ],
      ),
    );
  }
}
