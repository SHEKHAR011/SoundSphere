import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/song.dart';
import 'services/music_player_service.dart';
import 'services/user_music_service.dart';
import 'services/songs_provider.dart';
import 'package:just_audio/just_audio.dart';

class NowPlayingScreen extends StatefulWidget {
  final Song song;

  const NowPlayingScreen({super.key, required this.song});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  late final MusicPlayerService _musicPlayer;

  @override
  void initState() {
    super.initState();
    _musicPlayer = Provider.of<MusicPlayerService>(context, listen: false);
    _musicPlayer.playOrPause();
  }

  @override
  void dispose() {
    // Don't dispose the music player service as it's a singleton
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Album art placeholder
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade100,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        Icons.album,
                        size: 100,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      widget.song.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.song.artist,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    // Progress bar would go here
                    StreamBuilder<PlaybackState>(
                      stream: _musicPlayer.playbackStateStream,
                      builder: (context, snapshot) {
                        final playbackState = snapshot.data ?? 
                            PlaybackState(
                              playerState: PlayerState(false, ProcessingState.idle),
                              position: Duration.zero,
                              duration: Duration.zero,
                            );
                        
                        return Column(
                          children: [
                            Slider(
                              value: playbackState.progress,
                              onChanged: (value) {
                                final duration = playbackState.duration ?? Duration.zero;
                                _musicPlayer.seek(
                                  Duration(
                                    milliseconds: (duration.inMilliseconds * value).round(),
                                  ),
                                );
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(playbackState.position),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  _formatDuration(playbackState.duration ?? Duration.zero),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Player controls
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous, size: 40),
                  onPressed: () {
                    _musicPlayer.playPrevious();
                  },
                ),
                StreamBuilder<PlayerState>(
                  stream: _musicPlayer.playerStateStream,
                  builder: (context, snapshot) {
                    final playerState = snapshot.data;
                    final playing = playerState?.playing ?? false;
                    
                    return IconButton(
                      icon: Icon(
                        playing ? Icons.pause : Icons.play_arrow,
                        size: 60,
                        color: Colors.deepPurple,
                      ),
                      onPressed: () {
                        _musicPlayer.playOrPause();
                        setState(() {}); // Update UI
                      },
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, size: 40),
                  onPressed: () {
                    _musicPlayer.playNext();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '--:--';
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}