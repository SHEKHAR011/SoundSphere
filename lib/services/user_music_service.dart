import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/song.dart';

class UserMusicService extends ChangeNotifier {
  static final UserMusicService _instance = UserMusicService._internal();
  factory UserMusicService() => _instance;
  UserMusicService._internal();

  SharedPreferences? _prefs;
  List<Song> _recentlyPlayed = [];
  List<Song> _favorites = [];
  
  List<Song> get recentlyPlayed => _recentlyPlayed;
  List<Song> get favorites => _favorites;

  // Initialize shared preferences
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadRecentlyPlayed();
    await _loadFavorites();
  }

  // Recently Played functionality
  Future<void> addToRecentlyPlayed(Song song) async {
    try {
      // Remove if already exists
      _recentlyPlayed.removeWhere((s) => s.id == song.id);
      
      // Add to beginning of list
      _recentlyPlayed.insert(0, song);
      
      // Keep only last 50 recently played songs
      if (_recentlyPlayed.length > 50) {
        _recentlyPlayed = _recentlyPlayed.take(50).toList();
      }
      
      await _saveRecentlyPlayed();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding to recently played: $e');
    }
  }

  Future<void> _loadRecentlyPlayed() async {
    try {
      final String? recentlyPlayedJson = _prefs?.getString('recently_played');
      if (recentlyPlayedJson != null) {
        final List<dynamic> decoded = json.decode(recentlyPlayedJson);
        _recentlyPlayed = decoded.map((item) => Song.fromMap(Map<String, dynamic>.from(item))).toList();
      }
    } catch (e) {
      debugPrint('Error loading recently played: $e');
      _recentlyPlayed = [];
    }
  }
  
  Future<void> _saveRecentlyPlayed() async {
    try {
      final String encoded = json.encode(_recentlyPlayed.map((song) => song.toMap()).toList());
      await _prefs?.setString('recently_played', encoded);
    } catch (e) {
      debugPrint('Error saving recently played: $e');
    }
  }

  Future<void> clearRecentlyPlayed() async {
    try {
      _recentlyPlayed.clear();
      await _prefs?.remove('recently_played');
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing recently played: $e');
    }
  }

  // Favorites functionality
  Future<void> toggleFavorite(Song song) async {
    try {
      if (isFavorite(song)) {
        await _removeFavorite(song);
      } else {
        await _addFavorite(song);
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  Future<void> _addFavorite(Song song) async {
    try {
      if (!_favorites.any((s) => s.id == song.id)) {
        _favorites.insert(0, song);
        await _saveFavorites();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error adding favorite: $e');
    }
  }

  Future<void> _removeFavorite(Song song) async {
    try {
      _favorites.removeWhere((s) => s.id == song.id);
      await _saveFavorites();
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing favorite: $e');
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final String? favoritesJson = _prefs?.getString('favorites');
      if (favoritesJson != null) {
        final List<dynamic> decoded = json.decode(favoritesJson);
        _favorites = decoded.map((item) => Song.fromMap(Map<String, dynamic>.from(item))).toList();
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
      _favorites = [];
    }
  }
  
  Future<void> _saveFavorites() async {
    try {
      final String encoded = json.encode(_favorites.map((song) => song.toMap()).toList());
      await _prefs?.setString('favorites', encoded);
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  bool isFavorite(Song song) {
    return _favorites.any((favSong) => favSong.id == song.id);
  }

  // Get random songs from favorites for recommendations
  List<Song> getRandomFavorites({int limit = 5}) {
    final shuffled = List<Song>.from(_favorites)..shuffle();
    return shuffled.take(limit).toList();
  }
}