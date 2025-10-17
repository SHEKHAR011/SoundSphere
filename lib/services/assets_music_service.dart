import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as path;
import '../models/song.dart';

class AssetsMusicService {
  static const String musicAssetsPath = 'assets/music/';
  static const String imagesAssetsPath = 'assets/images/';
  
  // Predefined list of songs that should be in assets
  // In a real app, you would scan the actual asset directory
  static List<Song> predefinedSongs = [
    Song(
      title: 'Blinding Lights',
      artist: 'The Weeknd',
      album: 'After Hours',
      duration: '3:20',
      url: 'assets/music/blinding_lights.mp3',
    ),
    Song(
      title: 'Save Your Tears',
      artist: 'The Weeknd',
      album: 'After Hours',
      duration: '3:35',
      url: 'assets/music/save_your_tears.mp3',
    ),
    Song(
      title: 'Levitating',
      artist: 'Dua Lipa',
      album: 'Future Nostalgia',
      duration: '3:23',
      url: 'assets/music/levitating.mp3',
    ),
    Song(
      title: 'Stay',
      artist: 'The Kid LAROI, Justin Bieber',
      album: 'F*CK LOVE 3',
      duration: '2:59',
      url: 'assets/music/stay.mp3',
    ),
    Song(
      title: 'Good 4 U',
      artist: 'Olivia Rodrigo',
      album: 'SOUR',
      duration: '2:58',
      url: 'assets/music/good_4_u.mp3',
    ),
  ];

  // Get all songs from assets folder
  static Future<List<Song>> getAllSongsFromAssets() async {
    List<Song> availableSongs = [];
    
    // Check which predefined songs actually exist in assets
    for (int i = 0; i < predefinedSongs.length; i++) {
      if (await assetExists(predefinedSongs[i].url)) {
        availableSongs.add(
          Song(
            id: i,
            title: predefinedSongs[i].title,
            artist: predefinedSongs[i].artist,
            album: predefinedSongs[i].album,
            duration: predefinedSongs[i].duration,
            url: predefinedSongs[i].url,
            coverArt: 'assets/images/cover${i+1}.jpg', // Optional cover art
            dateAdded: DateTime.now(),
          ),
        );
      } else {
        // If the asset doesn't exist, still add it with a placeholder
        // In a real app, you might want to handle this differently
        availableSongs.add(
          Song(
            id: i,
            title: predefinedSongs[i].title,
            artist: predefinedSongs[i].artist,
            album: predefinedSongs[i].album,
            duration: predefinedSongs[i].duration,
            url: predefinedSongs[i].url,
            coverArt: 'assets/images/default_cover.jpg',
            dateAdded: DateTime.now(),
          ),
        );
      }
    }
    
    return availableSongs;
  }

  // Get a song by index
  static Future<Song?> getSongByIndex(int index) async {
    final songs = await getAllSongsFromAssets();
    if (index >= 0 && index < songs.length) {
      return songs[index];
    }
    return null;
  }

  // Get songs by directory scan (this is simulated since assets are static)
  static Future<List<Song>> getSongsFromDirectory() async {
    return getAllSongsFromAssets();
  }

  // Check if a file exists in assets
  static Future<bool> assetExists(String assetPath) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      return byteData.lengthInBytes > 0;
    } catch (e) {
      return false;
    }
  }
  
  // Get index of a song by its properties
  static Future<int?> getIndexBySong(Song song) async {
    final songs = await getAllSongsFromAssets();
    final index = songs.indexWhere((s) => s.url == song.url);
    return index != -1 ? index : null;
  }
  
  // Get total count of songs in assets
  static Future<int> getSongCount() async {
    final songs = await getAllSongsFromAssets();
    return songs.length;
  }
}