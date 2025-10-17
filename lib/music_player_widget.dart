import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/song.dart';
import 'services/music_player_service.dart';
import 'services/user_music_service.dart';
import 'package:just_audio/just_audio.dart';

/// A compact mini player shown at the bottom of the app.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final musicPlayer = Provider.of<MusicPlayerService>(context, listen: false);

    return Material(
      color: Colors.white,
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.music_note, color: Colors.deepPurple),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                musicPlayer.currentSong?.title ?? 'Not playing',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: StreamBuilder<PlayerState>(
                stream: musicPlayer.playerStateStream,
                builder: (context, snapshot) {
                  final playerState = snapshot.data;
                  final playing = playerState?.playing ?? false;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          playing ? Icons.pause : Icons.play_arrow,
                          color: Colors.deepPurple,
                        ),
                        onPressed: () => musicPlayer.playOrPause(),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.navigate_next,
                          color: Colors.deepPurple,
                        ),
                        onPressed: () => musicPlayer.playNext(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full screen Now Playing / Music Player widget.
class MusicPlayerWidget extends StatefulWidget {
  final Song song;

  const MusicPlayerWidget({Key? key, required this.song}) : super(key: key);

  @override
  _MusicPlayerWidgetState createState() => _MusicPlayerWidgetState();
}

class _MusicPlayerWidgetState extends State<MusicPlayerWidget>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final Animation<double> _rotationAnimation;
  late MusicPlayerService _musicPlayer;

  bool _isShuffle = false;
  bool _isRepeat = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_rotationController);
    _rotationController.repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _musicPlayer = Provider.of<MusicPlayerService>(context, listen: false);
    // Add to recently played (fire-and-forget)
    final userMusicService = Provider.of<UserMusicService>(
      context,
      listen: false,
    );
    userMusicService.addToRecentlyPlayed(widget.song);
    // initialize toggles from service if available
    try {
      _isShuffle = _musicPlayer.isShuffle;
      _isRepeat = _musicPlayer.isRepeat;
    } catch (_) {}
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '--:--';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final cover = widget.song.coverArt;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Now Playing',
          style: TextStyle(color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Album art with rotation
              RotationTransition(
                turns: _rotationAnimation,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                    image: cover != null
                        ? DecorationImage(
                            image: cover.startsWith('assets/')
                                ? AssetImage(cover) as ImageProvider
                                : NetworkImage(cover),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: cover == null
                      ? const Icon(
                          Icons.music_note,
                          size: 80,
                          color: Colors.deepPurple,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.song.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.song.artist,
                style: TextStyle(color: Colors.deepPurple.shade400),
              ),
              const SizedBox(height: 20),

              // Secondary controls: shuffle, repeat, playlist
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.shuffle,
                        color: _isShuffle
                            ? Colors.deepPurple
                            : Colors.deepPurple.shade200,
                      ),
                      onPressed: () {
                        setState(() {
                          _isShuffle = !_isShuffle;
                          try {
                            _musicPlayer.setShuffle(_isShuffle);
                          } catch (_) {}
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _isShuffle ? 'Shuffle On' : 'Shuffle Off',
                            ),
                            backgroundColor: Colors.deepPurple,
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.repeat,
                        color: _isRepeat
                            ? Colors.deepPurple
                            : Colors.deepPurple.shade200,
                      ),
                      onPressed: () {
                        setState(() {
                          _isRepeat = !_isRepeat;
                          try {
                            _musicPlayer.setRepeat(_isRepeat);
                          } catch (_) {}
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _isRepeat ? 'Repeat On' : 'Repeat Off',
                            ),
                            backgroundColor: Colors.deepPurple,
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.playlist_play,
                        color: Colors.deepPurple.shade300,
                      ),
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Queue coming soon'),
                              backgroundColor: Colors.deepPurple,
                            ),
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Progress slider
              StreamBuilder<PlaybackState>(
                stream: _musicPlayer.playbackStateStream,
                builder: (context, snapshot) {
                  final state = snapshot.data;
                  final position = state?.position ?? Duration.zero;
                  final duration = state?.duration ?? Duration.zero;
                  final progress = (duration.inMilliseconds > 0)
                      ? (position.inMilliseconds / duration.inMilliseconds)
                            .clamp(0.0, 1.0)
                      : 0.0;

                  return Column(
                    children: [
                      Slider(
                        value: progress,
                        onChanged: (v) {
                          final ms = (duration.inMilliseconds * v).round();
                          _musicPlayer.seek(Duration(milliseconds: ms));
                        },
                        activeColor: Colors.deepPurple,
                        inactiveColor: Colors.deepPurple.shade100,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(position),
                              style: TextStyle(
                                color: Colors.deepPurple.shade600,
                              ),
                            ),
                            Text(
                              _formatDuration(duration),
                              style: TextStyle(
                                color: Colors.deepPurple.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

              const Spacer(),

              // Main playback controls
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 28.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.deepPurple.shade100,
                      child: IconButton(
                        icon: Icon(
                          Icons.skip_previous,
                          color: Colors.deepPurple.shade700,
                        ),
                        onPressed: () => _musicPlayer.playPrevious(),
                      ),
                    ),
                    StreamBuilder<PlayerState>(
                      stream: _musicPlayer.playerStateStream,
                      builder: (context, snapshot) {
                        final playing = snapshot.data?.playing ?? false;
                        return Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.deepPurple.shade400,
                                Colors.deepPurple.shade600,
                              ],
                            ),
                          ),
                          child: IconButton(
                            iconSize: 56,
                            icon: Icon(
                              playing ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              _musicPlayer.playOrPause();
                              if (playing) {
                                _rotationController.stop();
                              } else {
                                _rotationController.repeat();
                              }
                            },
                          ),
                        );
                      },
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.deepPurple.shade100,
                      child: IconButton(
                        icon: Icon(
                          Icons.skip_next,
                          color: Colors.deepPurple.shade700,
                        ),
                        onPressed: () => _musicPlayer.playNext(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
