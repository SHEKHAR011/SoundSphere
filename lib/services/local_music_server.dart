import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/song.dart';
import 'assets_music_service.dart';

class LocalMusicServer {
  // Simulated server endpoints
  static const String baseUrl = 'http://localhost:8080';
  
  // Mock database of songs (in real implementation, this could be loaded from assets)
  static List<Song> _songs = [];
  
  // Initialize the server with asset songs
  static Future<void> initialize() async {
    _songs = await AssetsMusicService.getAllSongsFromAssets();
    
    // Add some dummy songs for demonstration
    _songs.addAll([
      Song(
        id: _songs.length + 0,
        title: 'Demo Song 1',
        artist: 'Demo Artist 1',
        album: 'Demo Album 1',
        duration: '3:25',
        url: 'assets/music/demo1.mp3',
        dateAdded: DateTime.now(),
      ),
      Song(
        id: _songs.length + 1,
        title: 'Demo Song 2',
        artist: 'Demo Artist 2',
        album: 'Demo Album 2',
        duration: '4:10',
        url: 'assets/music/demo2.mp3',
        dateAdded: DateTime.now(),
      ),
      Song(
        id: _songs.length + 2,
        title: 'Demo Song 3',
        artist: 'Demo Artist 3',
        album: 'Demo Album 3',
        duration: '3:50',
        url: 'assets/music/demo3.mp3',
        dateAdded: DateTime.now(),
      ),
    ]);
  }

  // GET /api/songs - Fetch all songs
  static Future<List<Song>> getAllSongs() async {
    await Future.delayed(const Duration(milliseconds: 200)); // Simulate network delay
    return _songs;
  }

  // GET /api/songs/:index - Fetch song by index
  static Future<Song?> getSongByIndex(int index) async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate network delay
    if (index >= 0 && index < _songs.length) {
      return _songs[index];
    }
    return null;
  }

  // GET /api/songs/search?q=query - Search songs
  static Future<List<Song>> searchSongs(String query) async {
    await Future.delayed(const Duration(milliseconds: 150)); // Simulate network delay
    if (query.isEmpty) return _songs;
    
    return _songs.where((song) => 
        song.title.toLowerCase().contains(query.toLowerCase()) ||
        song.artist.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // GET /api/songs/count - Get total song count
  static Future<int> getSongCount() async {
    await Future.delayed(const Duration(milliseconds: 50)); // Simulate network delay
    return _songs.length;
  }

  // GET /api/songs/random - Get random songs
  static Future<List<Song>> getRandomSongs({int limit = 5}) async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate network delay
    final shuffled = List<Song>.from(_songs)..shuffle();
    return shuffled.take(limit).toList();
  }

  // GET /api/songs/artist/:artist - Get songs by artist
  static Future<List<Song>> getSongsByArtist(String artist) async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate network delay
    return _songs.where((song) => 
        song.artist.toLowerCase().contains(artist.toLowerCase())
    ).toList();
  }

  // GET /api/songs/album/:album - Get songs by album
  static Future<List<Song>> getSongsByAlbum(String album) async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate network delay
    return _songs.where((song) => 
        song.album.toLowerCase().contains(album.toLowerCase())
    ).toList();
  }

  // GET /api/songs/range - Get songs in a range (e.g., for pagination)
  static Future<List<Song>> getSongsInRange({int start = 0, int count = 10}) async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate network delay
    int end = (start + count < _songs.length) ? start + count : _songs.length;
    
    if (start >= _songs.length) return [];
    
    return _songs.sublist(start, end);
  }

  // Get all available indexes
  static List<int> getIndexes() {
    return List.generate(_songs.length, (index) => index);
  }

  // Get song by ID (different from index)
  static Future<Song?> getSongById(int id) async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate network delay
    return _songs.firstWhere((song) => song.id == id, orElse: () => _songs[0]);
  }
}