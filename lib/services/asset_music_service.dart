import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as path;
import '../models/song.dart';

class AssetMusicService {
  static const String musicAssetsPath = 'assets/music/';
  static const String imagesAssetsPath = 'assets/images/';
  
  // Demo songs collection - replace filenames with actual .mp3 files in assets/music/
  // When you add real audio files, just update the filename field
  static List<Map<String, String>> songDefinitions = [
    // Punjabi/Hip-Hop
    {'title': 'Balenci', 'artist': 'Shubh', 'album': 'Still Rollin', 'duration': '3:45', 'filename': 'Balenci - Shubh.mp3'},
    {'title': 'College Dropout', 'artist': 'Jerry', 'album': 'Single', 'duration': '4:20', 'filename': 'College Dropout - Jerry.mp3'},
    {'title': 'Dapper Dan', 'artist': 'Navaan Sandhu', 'album': 'Single', 'duration': '3:15', 'filename': 'Dapper Dan - Navaan Sandhu.mp3'},
    {'title': 'For A Reason', 'artist': 'Karan Aujla', 'album': 'BTFU', 'duration': '4:10', 'filename': 'For A Reason - Karan Aujla.mp3'},
    {'title': 'Sajda', 'artist': 'Navaan Sandhu', 'album': 'Single', 'duration': '3:50', 'filename': 'Sajda - Navaan Sandhu.mp3'},
    {'title': 'Without Me', 'artist': 'AP Dhillon', 'album': 'Single', 'duration': '3:30', 'filename': 'Without Me - AP Dhillon.mp3'},
  ];

  // Load all songs from asset definitions
  static Future<List<Song>> loadSongsFromAssets() async {
    List<Song> songs = [];
    
    for (int i = 0; i < songDefinitions.length; i++) {
      Map<String, String> songDef = songDefinitions[i];
      String assetPath = '${musicAssetsPath}${songDef['filename']}';
      
      // Create song with asset path
      Song song = Song(
        id: i, // Using index as ID
        title: songDef['title'] ?? 'Unknown Title',
        artist: songDef['artist'] ?? 'Unknown Artist',
        album: songDef['album'] ?? 'Unknown Album',
        duration: songDef['duration'] ?? '0:00',
        url: assetPath,
        coverArt: '${imagesAssetsPath}cover${i+1}.jpg', // Optional cover art
        dateAdded: DateTime.now(),
      );
      
      // Add song to collection
      // Note: Audio files won't play without actual .mp3 files in assets/music/
      // But the app functionality (UI, favorites, etc.) works perfectly
      songs.add(song);
    }
    
    return songs;
  }

  // Get a song by its index in the assets folder
  static Future<Song?> getSongByIndex(int index) async {
    final songs = await loadSongsFromAssets();
    if (index >= 0 && index < songs.length) {
      return songs[index];
    }
    return null;
  }

  // Get all songs with their indices
  static Future<List<Song>> getAllSongsWithIndices() async {
    return await loadSongsFromAssets();
  }

  // Get total count of songs in assets
  static Future<int> getSongCount() async {
    final songs = await loadSongsFromAssets();
    return songs.length;
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
  
  // Get all available indices
  static Future<List<int>> getAllIndices() async {
    final songs = await loadSongsFromAssets();
    return List.generate(songs.length, (index) => index);
  }
}