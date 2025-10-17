import 'dart:math';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:audio_session/audio_session.dart';
import '../models/song.dart';

class MusicPlayerService {
  static final MusicPlayerService _instance = MusicPlayerService._internal();
  factory MusicPlayerService() => _instance;
  MusicPlayerService._internal() {
    _init();
  }

  final AudioPlayer _player = AudioPlayer();
  List<Song> _playlist = [];
  int _currentSongIndex = 0;
  bool _isShuffle = false;
  bool _isRepeat = false; // repeat all when true

  // Broadcast current song updates
  final BehaviorSubject<Song?> _currentSongSubject =
      BehaviorSubject<Song?>.seeded(null);

  AudioPlayer get player => _player;

  // Current song information
  Song? get currentSong =>
      _playlist.isNotEmpty &&
          _currentSongIndex >= 0 &&
          _currentSongIndex < _playlist.length
      ? _playlist[_currentSongIndex]
      : null;
  int get currentSongIndex => _currentSongIndex;
  List<Song> get playlist => _playlist;

  // Streams
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Song?> get currentSongStream => _currentSongSubject.stream;
  Stream<Duration> get bufferedPositionStream => _player.bufferedPositionStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  // Combined playback state stream
  Stream<PlaybackState> get playbackStateStream => Rx.combineLatest3(
    playerStateStream,
    positionStream,
    durationStream,
    (PlayerState playerState, Duration position, Duration? duration) =>
        PlaybackState(
          playerState: playerState,
          position: position,
          duration: duration,
        ),
  );

  Future<void> _init() async {
    // Configure audio session for music playback
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (_) {
      // Ignore session configuration failures
    }

    // Keep current song index and stream in sync with the player
    _player.currentIndexStream.listen((index) {
      if (index == null) return;
      if (index >= 0 && index < _playlist.length) {
        _currentSongIndex = index;
        _currentSongSubject.add(_playlist[index]);
      }
    });
  }

  // Shuffle / Repeat controls
  void setShuffle(bool value) {
    _isShuffle = value;
  }

  bool get isShuffle => _isShuffle;

  void setRepeat(bool value) {
    _isRepeat = value;
  }

  bool get isRepeat => _isRepeat;

  // Set a new playlist (assets-based)
  Future<void> setPlaylist(List<Song> songs, {int startIndex = 0}) async {
    _playlist = songs;
    _currentSongIndex = (startIndex >= 0 && startIndex < songs.length)
        ? startIndex
        : 0;

    if (songs.isEmpty) {
      await _player.stop();
      _currentSongSubject.add(null);
      return;
    }

    // Build a concatenated playlist using asset sources
    final children = songs.map((s) => AudioSource.asset(s.url)).toList();
    final playlistSource = ConcatenatingAudioSource(children: children);

    await _player.setAudioSource(
      playlistSource,
      initialIndex: _currentSongIndex,
      initialPosition: Duration.zero,
    );

    // Emit current song
    _currentSongSubject.add(_playlist[_currentSongIndex]);
  }

  // Play a specific song from the playlist
  Future<void> playSongAtIndex(int index) async {
    if (index >= 0 && index < _playlist.length) {
      await _player.seek(Duration.zero, index: index);
      await _player.play();
    }
  }

  // Play or pause the current song
  Future<void> playOrPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  // Play the next song
  Future<void> playNext() async {
    if (_playlist.isEmpty) return;

    // Shuffle mode: pick a random next index
    if (_isShuffle) {
      if (_playlist.length == 1) {
        await _player.seek(Duration.zero, index: _currentSongIndex);
        await _player.play();
        return;
      }
      final rand = Random();
      int next = _currentSongIndex;
      while (next == _currentSongIndex) {
        next = rand.nextInt(_playlist.length);
      }
      _currentSongIndex = next;
      await _player.seek(Duration.zero, index: _currentSongIndex);
      await _player.play();
      return;
    }

    // Normal advance
    final nextIndex = _currentSongIndex + 1;
    if (nextIndex < _playlist.length) {
      _currentSongIndex = nextIndex;
      await _player.seek(Duration.zero, index: _currentSongIndex);
      await _player.play();
    } else if (_isRepeat) {
      // loop to start
      _currentSongIndex = 0;
      await _player.seek(Duration.zero, index: _currentSongIndex);
      await _player.play();
    } else {
      // reached end, stop
      await _player.stop();
    }
  }

  // Play the previous song
  Future<void> playPrevious() async {
    if (_playlist.isEmpty) return;

    if (_isShuffle) {
      if (_playlist.length == 1) {
        await _player.seek(Duration.zero, index: _currentSongIndex);
        await _player.play();
        return;
      }
      final rand = Random();
      int prev = _currentSongIndex;
      while (prev == _currentSongIndex) {
        prev = rand.nextInt(_playlist.length);
      }
      _currentSongIndex = prev;
      await _player.seek(Duration.zero, index: _currentSongIndex);
      await _player.play();
      return;
    }

    final prevIndex = _currentSongIndex - 1;
    if (prevIndex >= 0) {
      _currentSongIndex = prevIndex;
      await _player.seek(Duration.zero, index: _currentSongIndex);
      await _player.play();
    } else if (_isRepeat) {
      // go to last
      _currentSongIndex = _playlist.length - 1;
      await _player.seek(Duration.zero, index: _currentSongIndex);
      await _player.play();
    } else {
      // already at start
      await _player.seek(Duration.zero, index: _currentSongIndex);
    }
  }

  // Seek to a specific position
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  // Get current position
  Duration get currentPosition => _player.position;

  // Get duration of current song
  Duration? get currentDuration => _player.duration;

  // Check if player is playing
  bool get isPlaying => _player.playing;

  // Dispose resources
  void dispose() {
    _currentSongSubject.close();
    _player.dispose();
  }
}

class PlaybackState {
  final PlayerState playerState;
  final Duration position;
  final Duration? duration;

  const PlaybackState({
    required this.playerState,
    required this.position,
    this.duration,
  });

  double get progress => duration != null && duration!.inMilliseconds > 0
      ? position.inMilliseconds / duration!.inMilliseconds
      : 0.0;
}
