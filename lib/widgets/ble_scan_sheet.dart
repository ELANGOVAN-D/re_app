import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class BleScanSheet extends StatelessWidget {
  const BleScanSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const BleScanSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.bluetooth_searching, color: Color(0xFFFF3B30)),
                const SizedBox(width: 12),
                const Text('BLE DEVICES',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, letterSpacing: 2)),
                const Spacer(),
                if (state.isScanning)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFFF3B30),
                    ),
                  ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: state.isScanning ? null : () => state.startScan(),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3B30).withOpacity(0.15),
                  ),
                  child: Text(state.isScanning ? 'SCANNING...' : 'SCAN'),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          Expanded(
            child: state.scanResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bluetooth_disabled,
                            size: 48, color: Colors.white24),
                        const SizedBox(height: 12),
                        Text(
                          state.isScanning
                              ? 'Searching for devices...'
                              : 'Tap SCAN to find devices',
                          style: const TextStyle(color: Colors.white38),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: state.scanResults.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (ctx, i) {
                      final r = state.scanResults[i];
                      final name = r.device.platformName.isNotEmpty
                          ? r.device.platformName
                          : 'Unknown Device';
                      final rssi = r.rssi;
                      return ListTile(
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF3B30).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.bluetooth,
                              color: Color(0xFFFF3B30)),
                        ),
                        title: Text(name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          r.device.remoteId.str,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.white38),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _SignalBars(rssi: rssi),
                            Text('$rssi dBm',
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.white38)),
                          ],
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          state.connect(r.device);
                        },
                      );
                    },
                  ),
          ),
          if (state.connectedDevice != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        color: Colors.greenAccent, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Connected: ${state.connectedDevice!.platformName}',
                      style: const TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _SignalBars extends StatelessWidget {
  final int rssi;
  const _SignalBars({required this.rssi});

  int get _bars {
    if (rssi >= -60) return 4;
    if (rssi >= -70) return 3;
    if (rssi >= -80) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (i) {
        final active = i < _bars;
        return Container(
          width: 4,
          height: 6.0 + i * 3,
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFFF3B30) : Colors.white12,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }
}
