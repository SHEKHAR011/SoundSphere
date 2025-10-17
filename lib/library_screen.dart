import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/song.dart';
import 'services/music_player_service.dart';
import 'services/user_music_service.dart';
import 'now_playing_screen.dart';
import 'music_player_widget.dart';
import 'services/songs_provider.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Music Library'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<SongsProvider>(
        builder: (context, songsProvider, child) {
          if (songsProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (songsProvider.songs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.music_note,
                    size: 80,
                    color: Colors.deepPurple.shade300,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No songs yet',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Add some songs to your library to get started',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: songsProvider.songs.length,
            itemBuilder: (context, index) {
              final song = songsProvider.songs[index];
              return _buildSongTile(context, song);
            },
          );
        },
      ),
    );
  }

  Widget _buildSongTile(BuildContext context, Song song) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.music_note,
            color: Colors.deepPurple,
          ),
        ),
        title: Text(
          song.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${song.artist} • ${song.album}',
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              song.duration,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 8),
            Consumer<UserMusicService>(
              builder: (context, userMusicService, child) {
                return IconButton(
                  icon: Icon(
                    userMusicService.isFavorite(song)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: userMusicService.isFavorite(song)
                        ? Colors.red
                        : Colors.grey,
                    size: 20,
                  ),
                  onPressed: () {
                    userMusicService.toggleFavorite(song);
                  },
                );
              },
            ),
          ],
        ),
        onTap: () {
          // Play this song
          final musicPlayer = Provider.of<MusicPlayerService>(context, listen: false);
          final userMusicService = Provider.of<UserMusicService>(context, listen: false);
          final songsProvider = Provider.of<SongsProvider>(context, listen: false);
          
          // Add to recently played
          userMusicService.addToRecentlyPlayed(song);
          
          // Find the index of the current song in the full song list
          final startIndex = songsProvider.songs.indexWhere((s) => s.id == song.id);
          
          // Set the playlist to all songs starting from this one
          musicPlayer.setPlaylist(songsProvider.songs, startIndex: startIndex);
          
          // Navigate to now playing screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NowPlayingScreen(song: song),
            ),
          );
        },
      ),
    );
  }
}

