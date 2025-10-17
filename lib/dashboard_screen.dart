import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/song.dart';
import 'services/music_player_service.dart';
import 'services/user_music_service.dart';
import 'now_playing_screen.dart';
import 'home_screen.dart';
import 'library_screen.dart';
import 'search_screen.dart';
import 'services/songs_provider.dart';
import 'user_session.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userSession = Provider.of<UserSession>(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.deepPurple.shade50,
            Colors.deepPurple.shade100,
            Colors.white,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.shade100,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.music_note,
                      size: 30,
                      color: Colors.deepPurple.shade700,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, ${userSession.userName}!',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          userSession.userEmail,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Features section
            const Text(
              'Your Music',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),

            // Music sections with real data
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recently Played Section
                    Consumer<UserMusicService>(
                      builder: (context, userMusicService, child) {
                        if (userMusicService.recentlyPlayed.isNotEmpty) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Recently Played',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        _showRecentlyPlayedScreen(context),
                                    child: const Text('See All'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 200,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: userMusicService.recentlyPlayed
                                      .take(5)
                                      .length,
                                  itemBuilder: (context, index) {
                                    final song =
                                        userMusicService.recentlyPlayed[index];
                                    return _buildSongCard(context, song);
                                  },
                                ),
                              ),
                              const SizedBox(height: 25),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    // Favorites Section
                    Consumer<UserMusicService>(
                      builder: (context, userMusicService, child) {
                        if (userMusicService.favorites.isNotEmpty) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Your Favorites',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        _showFavoritesScreen(context),
                                    child: const Text('See All'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 200,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: userMusicService.favorites
                                      .take(5)
                                      .length,
                                  itemBuilder: (context, index) {
                                    final song =
                                        userMusicService.favorites[index];
                                    return _buildSongCard(context, song);
                                  },
                                ),
                              ),
                              const SizedBox(height: 25),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    // Quick Actions Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      children: [
                        Consumer<UserMusicService>(
                          builder: (context, userMusicService, child) {
                            return _buildFeatureCard(
                              context,
                              icon: Icons.favorite,
                              title: 'Favorites',
                              subtitle:
                                  '${userMusicService.favorites.length} songs',
                              color: Colors.pink.shade300,
                              onTap: () => _showFavoritesScreen(context),
                            );
                          },
                        ),
                        Consumer<UserMusicService>(
                          builder: (context, userMusicService, child) {
                            return _buildFeatureCard(
                              context,
                              icon: Icons.history,
                              title: 'Recently Played',
                              subtitle:
                                  '${userMusicService.recentlyPlayed.length} songs',
                              color: Colors.deepPurple.shade300,
                              onTap: () => _showRecentlyPlayedScreen(context),
                            );
                          },
                        ),
                        _buildFeatureCard(
                          context,
                          icon: Icons.shuffle,
                          title: 'Shuffle All',
                          subtitle: 'Play random songs',
                          color: Colors.indigo.shade300,
                          onTap: () => _shuffleAllSongs(context),
                        ),
                        Consumer<SongsProvider>(
                          builder: (context, songsProvider, child) {
                            return _buildFeatureCard(
                              context,
                              icon: Icons.library_music,
                              title: 'All Songs',
                              subtitle: '${songsProvider.songs.length} songs',
                              color: Colors.purple.shade300,
                              onTap: () {
                                // Navigate to library tab
                                DefaultTabController.of(context)?.animateTo(2);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongCard(BuildContext context, Song song) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => _playSong(context, song),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade200,
                    Colors.deepPurple.shade500,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.shade200,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.music_note,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              song.title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              song.artist,
              style: TextStyle(color: Colors.grey[600], fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.shade100,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  // Navigation and action methods
  void _playSong(BuildContext context, Song song) {
    final musicPlayer = Provider.of<MusicPlayerService>(context, listen: false);
    UserMusicService userMusicService = Provider.of<UserMusicService>(
      context,
      listen: false,
    );

    userMusicService.addToRecentlyPlayed(song);
    musicPlayer.setPlaylist([song]);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NowPlayingScreen(song: song)),
    );
  }

  void _showRecentlyPlayedScreen(BuildContext context) {
    final userMusicService = Provider.of<UserMusicService>(
      context,
      listen: false,
    );
    _showSongList(context, 'Recently Played', userMusicService.recentlyPlayed);
  }

  void _showFavoritesScreen(BuildContext context) {
    final userMusicService = Provider.of<UserMusicService>(
      context,
      listen: false,
    );
    _showSongList(context, 'Favorites', userMusicService.favorites);
  }

  void _shuffleAllSongs(BuildContext context) async {
    final songsProvider = Provider.of<SongsProvider>(context, listen: false);
    final musicPlayer = Provider.of<MusicPlayerService>(context, listen: false);

    if (songsProvider.songs.isNotEmpty) {
      final shuffledSongs = List<Song>.from(songsProvider.songs)..shuffle();
      musicPlayer.setPlaylist(shuffledSongs);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NowPlayingScreen(song: shuffledSongs.first),
        ),
      );
    }
  }

  void _showSongList(BuildContext context, String title, List<Song> songs) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SongListScreen(title: title, songs: songs),
      ),
    );
  }
}

// Screen to show list of songs
class SongListScreen extends StatelessWidget {
  final String title;
  final List<Song> songs;

  const SongListScreen({super.key, required this.title, required this.songs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: songs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.music_note, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 20),
                  Text(
                    'No songs yet',
                    style: TextStyle(fontSize: 20, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return _buildSongTile(context, song, index);
              },
            ),
    );
  }

  Widget _buildSongTile(BuildContext context, Song song, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade200, Colors.deepPurple.shade400],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.music_note, color: Colors.white),
        ),
        title: Text(
          song.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${song.artist} • ${song.album}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Consumer<UserMusicService>(
          builder: (context, userMusicService, child) {
            return IconButton(
              icon: Icon(
                userMusicService.isFavorite(song)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: userMusicService.isFavorite(song)
                    ? Colors.red
                    : Colors.grey,
              ),
              onPressed: () {
                userMusicService.toggleFavorite(song);
              },
            );
          },
        ),
        onTap: () {
          // Play this song
          final musicPlayer = Provider.of<MusicPlayerService>(
            context,
            listen: false,
          );
          final userMusicService = Provider.of<UserMusicService>(
            context,
            listen: false,
          );

          // Add to recently played
          userMusicService.addToRecentlyPlayed(song);

          // Set playlist starting from this song
          musicPlayer.setPlaylist(songs, startIndex: index);

          // Navigate to now playing screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NowPlayingScreen(song: song),
            ),
          );
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.white,
      ),
    );
  }
}
