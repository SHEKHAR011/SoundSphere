import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import '../models/song.dart';

// Mock player state to simulate just_audio's PlayerState
class MockPlayerState {
  final bool playing;
  final MockProcessingState processingState;

  const MockPlayerState(this.playing, this.processingState);
}

enum MockProcessingState {
  idle,
  loading,
  buffering,
  ready,
  completed
}

class MockMusicPlayerService {
  static final MockMusicPlayerService _instance = MockMusicPlayerService._internal();
  factory MockMusicPlayerService() => _instance;
  MockMusicPlayerService._internal();

  List<Song> _playlist = [];
  int _currentSongIndex = 0;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration? _duration;
  Timer? _progressTimer;

  // Broadcast streams
  final BehaviorSubject<Song?> _currentSongSubject = BehaviorSubject<Song?>.seeded(null);
  final BehaviorSubject<MockPlayerState> _playerStateSubject = BehaviorSubject<MockPlayerState>.seeded(
    const MockPlayerState(false, MockProcessingState.idle)
  );
  final BehaviorSubject<Duration> _positionSubject = BehaviorSubject<Duration>.seeded(Duration.zero);
  final BehaviorSubject<Duration?> _durationSubject = BehaviorSubject<Duration?>.seeded(null);

  // Current song information
  Song? get currentSong => _playlist.isNotEmpty && _currentSongIndex >= 0 && _currentSongIndex < _playlist.length
      ? _playlist[_currentSongIndex]
      : null;
  int get currentSongIndex => _currentSongIndex;
  List<Song> get playlist => _playlist;
  bool get isPlaying => _isPlaying;
  Duration get currentPosition => _position;
  Duration? get currentDuration => _duration;

  // Streams
  Stream<MockPlayerState> get playerStateStream => _playerStateSubject.stream;
  Stream<Duration> get positionStream => _positionSubject.stream;
  Stream<Song?> get currentSongStream => _currentSongSubject.stream;
  Stream<Duration?> get durationStream => _durationSubject.stream;

  // Combined playback state stream
  Stream<PlaybackState> get playbackStateStream => Rx.combineLatest3(
    playerStateStream,
    positionStream,
    durationStream,
    (MockPlayerState playerState, Duration position, Duration? duration) => PlaybackState(
      playing: playerState.playing,
      position: position,
      duration: duration,
    ),
  );

  // Set a new playlist
  Future<void> setPlaylist(List<Song> songs, {int startIndex = 0}) async {
    _playlist = songs;
    _currentSongIndex = (startIndex >= 0 && startIndex < songs.length) ? startIndex : 0;

    if (songs.isEmpty) {
      await stop();
      _currentSongSubject.add(null);
      return;
    }

    // Simulate setting up the song
    await _loadCurrentSong();
    _currentSongSubject.add(_playlist[_currentSongIndex]);
  }

  Future<void> _loadCurrentSong() async {
    if (_currentSongIndex >= 0 && _currentSongIndex < _playlist.length) {
      final song = _playlist[_currentSongIndex];
      // Parse duration from song.duration string (e.g., "3:45")
      _duration = _parseDuration(song.duration);
      _position = Duration.zero;
      
      _durationSubject.add(_duration);
      _positionSubject.add(_position);
      _playerStateSubject.add(const MockPlayerState(false, MockProcessingState.ready));
      
      debugPrint('Mock player loaded: ${song.title} by ${song.artist}');
    }
  }

  Duration _parseDuration(String durationString) {
    try {
      final parts = durationString.split(':');
      if (parts.length == 2) {
        final minutes = int.tryParse(parts[0]) ?? 0;
        final seconds = int.tryParse(parts[1]) ?? 0;
        return Duration(minutes: minutes, seconds: seconds);
      }
    } catch (e) {
      debugPrint('Error parsing duration: $e');
    }
    return const Duration(minutes: 3, seconds: 30); // Default duration
  }

  // Play a specific song from the playlist
  Future<void> playSongAtIndex(int index) async {
    if (index >= 0 && index < _playlist.length) {
      _currentSongIndex = index;
      await _loadCurrentSong();
      _currentSongSubject.add(_playlist[_currentSongIndex]);
      await play();
    }
  }

  // Play or pause the current song
  Future<void> playOrPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> play() async {
    if (_playlist.isEmpty || _currentSongIndex >= _playlist.length) return;
    
    _isPlaying = true;
    _playerStateSubject.add(const MockPlayerState(true, MockProcessingState.ready));
    
    // Start progress timer
    _startProgressTimer();
    
    final song = _playlist[_currentSongIndex];
    debugPrint('Mock player started playing: ${song.title}');
  }

  Future<void> pause() async {
    _isPlaying = false;
    _progressTimer?.cancel();
    _playerStateSubject.add(const MockPlayerState(false, MockProcessingState.ready));
    
    debugPrint('Mock player paused');
  }

  Future<void> stop() async {
    _isPlaying = false;
    _position = Duration.zero;
    _progressTimer?.cancel();
    _positionSubject.add(_position);
    _playerStateSubject.add(const MockPlayerState(false, MockProcessingState.idle));
    
    debugPrint('Mock player stopped');
  }

  void _startProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }
      
      _position = Duration(seconds: _position.inSeconds + 1);
      _positionSubject.add(_position);
      
      // Check if song has ended
      if (_duration != null && _position >= _duration!) {
        timer.cancel();
        _onSongEnded();
      }
    });
  }

  void _onSongEnded() async {
    debugPrint('Mock song ended, playing next...');
    if (_currentSongIndex < _playlist.length - 1) {
      await playNext();
    } else {
      // End of playlist
      await stop();
    }
  }

  // Play the next song
  Future<void> playNext() async {
    if (_playlist.isEmpty) return;
    
    if (_currentSongIndex < _playlist.length - 1) {
      _currentSongIndex++;
      await _loadCurrentSong();
      _currentSongSubject.add(_playlist[_currentSongIndex]);
      if (_isPlaying) {
        await play();
      }
    }
  }

  // Play the previous song
  Future<void> playPrevious() async {
    if (_playlist.isEmpty) return;
    
    if (_currentSongIndex > 0) {
      _currentSongIndex--;
      await _loadCurrentSong();
      _currentSongSubject.add(_playlist[_currentSongIndex]);
      if (_isPlaying) {
        await play();
      }
    }
  }

  // Seek to a specific position
  Future<void> seek(Duration position) async {
    if (_duration != null && position <= _duration!) {
      _position = position;
      _positionSubject.add(_position);
      debugPrint('Mock player seeked to: ${position.inSeconds}s');
    }
  }

  // Dispose resources
  void dispose() {
    _progressTimer?.cancel();
    _currentSongSubject.close();
    _playerStateSubject.close();
    _positionSubject.close();
    _durationSubject.close();
  }
}

// Mock playback state class
class PlaybackState {
  final bool playing;
  final Duration position;
  final Duration? duration;

  const PlaybackState({
    required this.playing,
    required this.position,
    this.duration,
  });

  double get progress => duration != null && duration!.inMilliseconds > 0
      ? position.inMilliseconds / duration!.inMilliseconds
      : 0.0;
}