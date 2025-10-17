import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/asset_music_service.dart';

class SongsProvider extends ChangeNotifier {
  List<Song> _songs = [];
  bool _isLoading = false;

  List<Song> get songs => _songs;
  bool get isLoading => _isLoading;

  SongsProvider() {
    loadSongs();
  }

  Future<void> loadSongs() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Load songs directly from assets
      _songs = await AssetMusicService.getAllSongsWithIndices();
      debugPrint('Loaded ${_songs.length} songs from assets');
    } catch (e) {
      debugPrint('Error loading songs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSong(Song song) async {
    // No-op since we're only using asset-based songs
    debugPrint('Adding songs from UI is disabled. Using only assets.');
  }

  Future<void> removeSong(int id) async {
    // No-op since we're only using asset-based songs
    debugPrint('Removing songs is disabled. Using only assets.');
  }

  Future<List<Song>> searchSongs(String query) async {
    if (query.isEmpty) {
      return _songs;
    }
    return _songs.where((song) => 
        song.title.toLowerCase().contains(query.toLowerCase()) ||
        song.artist.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  Future<List<Song>> getSongsByArtist(String artist) async {
    return _songs.where((song) => 
        song.artist.toLowerCase().contains(artist.toLowerCase())
    ).toList();
  }

  Future<List<Song>> getSongsByAlbum(String album) async {
    return _songs.where((song) => 
        song.album.toLowerCase().contains(album.toLowerCase())
    ).toList();
  }

  int get songsCount => _songs.length;
}