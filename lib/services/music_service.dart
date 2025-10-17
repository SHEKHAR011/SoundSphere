import '../models/song.dart';
import 'songs_database.dart';
import 'assets_music_service.dart';
import 'local_music_server.dart';

class MusicService {
  // Initialize the local server
  static Future<void> initialize() async {
    await LocalMusicServer.initialize();
  }
  
  // Add song to local storage (database)
  static Future<int> addSongToLocalStorage(Song song) async {
    return await SongsDatabase.instance.createSong(song);
  }

  // Get all songs - combining both local storage and assets
  static Future<List<Song>> getAllSongs() async {
    // Get songs from database (user-added songs)
    final dbSongs = await SongsDatabase.instance.readAllSongs();
    
    // Get songs from assets (pre-installed songs) via the local server
    final assetSongs = await LocalMusicServer.getAllSongs();
    
    // Combine both lists
    final allSongs = [...dbSongs, ...assetSongs];
    
    // Sort by date added (newest first)
    allSongs.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    
    return allSongs;
  }

  // Get songs from local storage only
  static Future<List<Song>> getLocalSongs() async {
    return await SongsDatabase.instance.readAllSongs();
  }

  // Get songs from assets only (via local server)
  static Future<List<Song>> getAssetSongs() async {
    return await LocalMusicServer.getAllSongs();
  }

  // Get song by index (via local server)
  static Future<Song?> getSongByIndex(int index) async {
    return await LocalMusicServer.getSongByIndex(index);
  }

  // Delete song from local storage (can't delete asset songs)
  static Future<int> deleteSong(int id) async {
    return await SongsDatabase.instance.deleteSong(id);
  }

  // Search songs in both local storage and assets
  static Future<List<Song>> searchSongs(String query) async {
    if (query.isEmpty) {
      return await getAllSongs();
    }
    
    final dbSongs = await SongsDatabase.instance.searchSongs(query);
    final assetSongs = await LocalMusicServer.searchSongs(query);
    
    // Combine and sort
    final allSongs = [...dbSongs, ...assetSongs];
    allSongs.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    
    return allSongs;
  }

  // Get song count (via local server for assets)
  static Future<int> getSongsCount() async {
    final dbSongs = await SongsDatabase.instance.readAllSongs();
    final assetSongsCount = await LocalMusicServer.getSongCount();
    return dbSongs.length + assetSongsCount;
  }

  // Check if asset exists
  static Future<bool> assetExists(String assetPath) async {
    return await AssetsMusicService.assetExists(assetPath);
  }
  
  // Get random songs from local server
  static Future<List<Song>> getRandomSongs({int limit = 5}) async {
    return await LocalMusicServer.getRandomSongs(limit: limit);
  }
  
  // Get songs by range (pagination)
  static Future<List<Song>> getSongsInRange({int start = 0, int count = 10}) async {
    return await LocalMusicServer.getSongsInRange(start: start, count: count);
  }
}