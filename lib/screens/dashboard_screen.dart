import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_state.dart';
import '../widgets/glass_card.dart';
import '../widgets/pulse_ring.dart';
import '../widgets/ble_scan_sheet.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: Text(
            'STEALTH BRIDGE',
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.w900, letterSpacing: 2),
          ),
          backgroundColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A0000), Color(0xFF050505)],
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => BleScanSheet.show(context),
              icon: Icon(
                Icons.bluetooth_searching,
                color: state.connectedDevice != null
                    ? Colors.greenAccent
                    : Colors.white54,
              ),
            ),
            IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none)),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _ConnectionCard(state: state),
              const SizedBox(height: 16),
              _WeatherWidget(state: state),
              const SizedBox(height: 16),
              _MusicPlayerCard(state: state),
              const SizedBox(height: 16),
              const _QuickActionsRow(),
              const SizedBox(height: 16),
              _RideStatsRow(state: state),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ],
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  final AppState state;
  const _ConnectionCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final connected = state.connectedDevice != null;
    return GlassCard(
      borderColor: connected
          ? Colors.greenAccent.withValues(alpha: 0.3)
          : Colors.redAccent.withValues(alpha: 0.15),
      child: Row(
        children: [
          PulseRing(isActive: connected),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CONNECTION',
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.4),
                        letterSpacing: 1.5)),
                const SizedBox(height: 4),
                Text(
                  connected
                      ? state.connectedDevice!.platformName.isNotEmpty
                          ? state.connectedDevice!.platformName
                          : 'TRIPPER CONNECTED'
                      : 'TRIPPER NOT FOUND',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
          ),
          FilledButton.tonal(
            onPressed: () => BleScanSheet.show(context),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF3B30).withValues(alpha: 0.12),
            ),
            child: Text(
              connected ? 'MANAGE' : 'CONNECT',
              style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherWidget extends StatelessWidget {
  final AppState state;
  const _WeatherWidget({required this.state});

  String _weatherIcon(int code) {
    if (code == 0) return '☀️';
    if (code <= 3) return '⛅';
    if (code <= 67) return '🌧️';
    if (code <= 77) return '🌨️';
    return '⛈️';
  }

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingWeather) {
      return const GlassCard(
        child: Center(
          child: SizedBox(
            height: 40,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: Color(0xFFFF3B30)),
          ),
        ),
      );
    }
    if (state.weatherError.isNotEmpty || state.weatherData == null) {
      return GlassCard(
        child: Row(
          children: [
            const Icon(Icons.cloud_off, color: Colors.white38),
            const SizedBox(width: 12),
            Expanded(
                child: Text(
              state.weatherError.isNotEmpty
                  ? state.weatherError
                  : 'Weather unavailable',
              style: const TextStyle(color: Colors.white54),
            )),
            IconButton(
              onPressed: () => state.fetchWeather(),
              icon: const Icon(Icons.refresh, color: Color(0xFFFF3B30)),
            ),
          ],
        ),
      );
    }
    final cw = state.weatherData!['current_weather'] as Map<String, dynamic>;
    final temp = (cw['temperature'] as num).toDouble();
    final wind = (cw['windspeed'] as num).toDouble();
    final code = (cw['weathercode'] as num).toInt();
    return GlassCard(
      child: Row(
        children: [
          Text(_weatherIcon(code), style: const TextStyle(fontSize: 36)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CURRENT WEATHER',
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.4),
                        letterSpacing: 1.5)),
                const SizedBox(height: 4),
                Text('${temp.toStringAsFixed(1)}°C  •  ${wind.toStringAsFixed(0)} km/h wind',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => state.fetchWeather(),
            child: const Text('REFRESH',
                style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFFFF3B30),
                    letterSpacing: 1)),
          ),
        ],
      ),
    );
  }
}

class _MusicPlayerCard extends StatelessWidget {
  final AppState state;
  const _MusicPlayerCard({required this.state});

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
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.music_note_rounded,
                  color: Colors.redAccent, size: 16),
              const SizedBox(width: 8),
              Text('NOW PLAYING',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 2,
                      color: Colors.white.withValues(alpha: 0.6))),
              const Spacer(),
              if (state.isPlayingLocal)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('LOCAL',
                      style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 9,
                          fontWeight: FontWeight.bold)),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('STREAMING',
                      style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 9,
                          fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(state.currentSong,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w900),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(state.currentArtist,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: state.isPlayingLocal ? 0.4 : 0.3,
            backgroundColor: Colors.white10,
            valueColor:
                const AlwaysStoppedAnimation<Color>(Color(0xFFFF3B30)),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _ActionBtn(
          icon: Icons.sos_rounded,
          label: 'SOS',
          color: Colors.redAccent,
          onTap: () async {
            final uri = Uri.parse('tel:112');
            if (await canLaunchUrl(uri)) launchUrl(uri);
          },
        )),
        const SizedBox(width: 12),
        Expanded(
            child: _ActionBtn(
          icon: Icons.local_gas_station,
          label: 'FUEL',
          color: Colors.orange,
          onTap: () async {
            final uri = Uri.parse(
                'https://www.google.com/maps/search/?api=1&query=petrol+pump+near+me');
            if (await canLaunchUrl(uri)) {
              launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
        )),
        const SizedBox(width: 12),
        Expanded(
            child: _ActionBtn(
          icon: Icons.build_rounded,
          label: 'SERVICE',
          color: Colors.blueAccent,
          onTap: () async {
            final uri = Uri.parse(
                'https://www.google.com/maps/search/?api=1&query=royal+enfield+service+center+near+me');
            if (await canLaunchUrl(uri)) {
              launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
        )),
        const SizedBox(width: 12),
        Expanded(
            child: _ActionBtn(
          icon: Icons.map_rounded,
          label: 'MAPS',
          color: Colors.greenAccent,
          onTap: () async {
            final uri = Uri.parse('https://maps.google.com');
            if (await canLaunchUrl(uri)) {
              launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
        )),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}

class _RideStatsRow extends StatelessWidget {
  final AppState state;
  const _RideStatsRow({required this.state});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(
              label: 'SPEED',
              value: '${state.currentSpeed.toInt()}',
              unit: 'km/h'),
          _divider(),
          _Stat(
              label: 'DISTANCE',
              value: state.totalDistance.toStringAsFixed(1),
              unit: 'km'),
          _divider(),
          _Stat(
              label: 'MAX',
              value: '${state.maxSpeed.toInt()}',
              unit: 'km/h'),
          _divider(),
          _Stat(
              label: 'TRIPS',
              value: '${state.rideHistory.length}',
              unit: 'total'),
        ],
      ),
    );
  }

  Widget _divider() => Container(
      width: 1, height: 40, color: Colors.white.withValues(alpha: 0.08));
}

class _Stat extends StatelessWidget {
  final String label, value, unit;
  const _Stat({required this.label, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 9, color: Colors.white38, letterSpacing: 1.5)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFFFF3B30))),
        Text(unit,
            style:
                const TextStyle(fontSize: 9, color: Colors.white38)),
      ],
    );
  }
}
