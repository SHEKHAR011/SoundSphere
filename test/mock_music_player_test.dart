import 'package:flutter_test/flutter_test.dart';
import 'package:soundsphere/services/mock_music_player_service.dart';
import 'package:soundsphere/models/song.dart';

void main() {
  group('MockMusicPlayerService Tests', () {
    late MockMusicPlayerService player;
    late List<Song> testSongs;

    setUp(() {
      player = MockMusicPlayerService();
      testSongs = [
        Song(
          id: 1,
          title: 'Test Song 1',
          artist: 'Test Artist 1',
          album: 'Test Album',
          duration: '3:30',
          url: 'assets/music/test1.mp3',
        ),
        Song(
          id: 2,
          title: 'Test Song 2',
          artist: 'Test Artist 2',
          album: 'Test Album',
          duration: '4:15',
          url: 'assets/music/test2.mp3',
        ),
      ];
    });

    test('should set playlist correctly', () async {
      await player.setPlaylist(testSongs);
      
      expect(player.playlist, equals(testSongs));
      expect(player.currentSongIndex, equals(0));
      expect(player.currentSong, equals(testSongs[0]));
    });

    test('should play and pause correctly', () async {
      await player.setPlaylist(testSongs);
      
      // Initially not playing
      expect(player.isPlaying, false);
      
      // Start playing
      await player.play();
      expect(player.isPlaying, true);
      
      // Pause
      await player.pause();
      expect(player.isPlaying, false);
    });

    test('should navigate between songs correctly', () async {
      await player.setPlaylist(testSongs);
      
      // Start with first song
      expect(player.currentSongIndex, equals(0));
      
      // Go to next song
      await player.playNext();
      expect(player.currentSongIndex, equals(1));
      expect(player.currentSong, equals(testSongs[1]));
      
      // Go back to previous song
      await player.playPrevious();
      expect(player.currentSongIndex, equals(0));
      expect(player.currentSong, equals(testSongs[0]));
    });

    test('should seek to specific position', () async {
      await player.setPlaylist(testSongs);
      
      const seekPosition = Duration(seconds: 30);
      await player.seek(seekPosition);
      
      expect(player.currentPosition, equals(seekPosition));
    });

    test('should parse duration correctly', () async {
      await player.setPlaylist(testSongs);
      
      // The mock player should parse "3:30" to 3 minutes 30 seconds
      expect(player.currentDuration, equals(const Duration(minutes: 3, seconds: 30)));
    });
  });
}