import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../widgets/glass_card.dart';

class LocalMusicScreen extends StatelessWidget {
  const LocalMusicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('LOCAL MUSIC',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
        actions: [
          if (state.isPlayingLocal)
            IconButton(
              onPressed: state.stopLocalMusic,
              icon: const Icon(Icons.stop_circle, color: Colors.redAccent),
            ),
        ],
      ),
      body: Column(
        children: [
          if (state.isPlayingLocal) _NowPlayingBanner(state: state),
          Expanded(
            child: state.localSongs.isEmpty
                ? const _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: state.localSongs.length,
                    itemBuilder: (ctx, i) {
                      final song = state.localSongs[i];
                      final isPlaying =
                          state.isPlayingLocal && state.currentSong == song.title;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isPlaying
                              ? Colors.pinkAccent.withOpacity(0.08)
                              : const Color(0xFF111111),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isPlaying
                                ? Colors.pinkAccent.withOpacity(0.3)
                                : Colors.white.withOpacity(0.04),
                          ),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.pinkAccent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isPlaying ? Icons.equalizer_rounded : Icons.music_note_rounded,
                              color: Colors.pinkAccent,
                            ),
                          ),
                          title: Text(song.title,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isPlaying ? Colors.pinkAccent : Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          subtitle: Text(song.artist ?? 'Unknown Artist',
                              style: const TextStyle(fontSize: 12, color: Colors.white38),
                              maxLines: 1),
                          trailing: IconButton(
                            icon: Icon(
                              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                              color: Colors.pinkAccent,
                              size: 32,
                            ),
                            onPressed: () => isPlaying
                                ? state.stopLocalMusic()
                                : state.playLocalSong(song),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _NowPlayingBanner extends StatelessWidget {
  final AppState state;
  const _NowPlayingBanner({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: GlassCard(
        borderColor: Colors.pinkAccent.withOpacity(0.3),
        child: Row(
          children: [
            const Icon(Icons.music_note_rounded, color: Colors.pinkAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(state.currentSong,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(state.currentArtist,
                      style: const TextStyle(fontSize: 12, color: Colors.white54)),
                ],
              ),
            ),
            IconButton(
              onPressed: state.stopLocalMusic,
              icon: const Icon(Icons.stop_circle_outlined, color: Colors.pinkAccent),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.library_music_outlined, size: 64, color: Colors.white12),
          SizedBox(height: 16),
          Text('No songs found', style: TextStyle(color: Colors.white38, fontSize: 16)),
          SizedBox(height: 8),
          Text('Grant storage permission & try again',
              style: TextStyle(color: Colors.white24, fontSize: 12)),
        ],
      ),
    );
  }
}
