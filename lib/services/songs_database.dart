import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/song.dart';

class SongsDatabase {
  static final SongsDatabase instance = SongsDatabase._init();
  static Database? _database;

  SongsDatabase._init();

  String get songTable => 'songs';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'songs_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $songTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        artist TEXT NOT NULL,
        album TEXT NOT NULL,
        duration TEXT NOT NULL,
        url TEXT NOT NULL UNIQUE,
        coverArt TEXT,
        dateAdded INTEGER NOT NULL
      )
    ''');
  }

  // Create
  Future<int> createSong(Song song) async {
    final db = await instance.database;
    return await db.insert(songTable, song.toMap());
  }

  // Read all songs
  Future<List<Song>> readAllSongs() async {
    final db = await instance.database;
    final result = await db.query(
      songTable,
      orderBy: 'dateAdded DESC',
    );
    return result.map((json) => Song.fromMap(json)).toList();
  }

  // Read songs by artist
  Future<List<Song>> readSongsByArtist(String artist) async {
    final db = await instance.database;
    final result = await db.query(
      songTable,
      where: 'artist = ?',
      whereArgs: [artist],
      orderBy: 'dateAdded DESC',
    );
    return result.map((json) => Song.fromMap(json)).toList();
  }

  // Read songs by album
  Future<List<Song>> readSongsByAlbum(String album) async {
    final db = await instance.database;
    final result = await db.query(
      songTable,
      where: 'album = ?',
      whereArgs: [album],
      orderBy: 'dateAdded DESC',
    );
    return result.map((json) => Song.fromMap(json)).toList();
  }

  // Search songs by title or artist
  Future<List<Song>> searchSongs(String query) async {
    final db = await instance.database;
    final result = await db.query(
      songTable,
      where: 'title LIKE ? OR artist LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'dateAdded DESC',
    );
    return result.map((json) => Song.fromMap(json)).toList();
  }

  // Update
  Future<int> updateSong(Song song) async {
    final db = await instance.database;
    return await db.update(
      songTable,
      song.toMap(),
      where: 'id = ?',
      whereArgs: [song.id],
    );
  }

  // Delete
  Future<int> deleteSong(int id) async {
    final db = await instance.database;
    return await db.delete(
      songTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Count
  Future<int> countSongs() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM $songTable');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}