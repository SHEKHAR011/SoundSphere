import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/song.dart';
import 'services/music_player_service.dart';
import 'services/user_music_service.dart';
import 'now_playing_screen.dart';
import 'services/songs_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Song> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.isNotEmpty) {
      _performSearch(_searchController.text);
    } else {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final songsProvider = Provider.of<SongsProvider>(context, listen: false);
      final results = await songsProvider.searchSongs(query);
      
      setState(() {
        _searchResults = results;
        _hasSearched = true;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _hasSearched = true;
        _isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error searching: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Search Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Search Music',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
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
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search for songs, artists, albums...',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.deepPurple,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Search Results
              Expanded(
                child: _buildSearchContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchContent() {
    if (_isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Searching...'),
          ],
        ),
      );
    }

    if (!_hasSearched) {
      return _buildSearchSuggestions();
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Try searching with different keywords',
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final song = _searchResults[index];
        return _buildSongTile(song, index);
      },
    );
  }

  Widget _buildSearchSuggestions() {
    return Consumer<SongsProvider>(
      builder: (context, songsProvider, child) {
        // Show popular artists and recent searches
        final popularArtists = _getPopularArtists(songsProvider.songs);
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Browse by Artist',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: popularArtists.map((artist) {
                  return GestureDetector(
                    onTap: () {
                      _searchController.text = artist;
                      _performSearch(artist);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        artist,
                        style: TextStyle(
                          color: Colors.deepPurple.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              const Text(
                'Quick Search',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 16),
              _buildQuickSearchItem(
                Icons.trending_up,
                'Trending Songs',
                'Discover popular music',
                () => _performSearch('trending'),
              ),
              _buildQuickSearchItem(
                Icons.new_releases,
                'New Releases',
                'Latest added songs',
                () => _performSearch('new'),
              ),
              _buildQuickSearchItem(
                Icons.favorite,
                'Love Songs',
                'Romantic music collection',
                () => _performSearch('love'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickSearchItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.deepPurple,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.white,
      ),
    );
  }

  Widget _buildSongTile(Song song, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple.shade200,
                Colors.deepPurple.shade400,
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.music_note,
            color: Colors.white,
          ),
        ),
        title: Text(
          song.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${song.artist} • ${song.album}',
          style: TextStyle(
            color: Colors.grey[600],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
            Icon(
              Icons.play_arrow,
              color: Colors.deepPurple.shade400,
            ),
          ],
        ),
        onTap: () {
          // Play the song
          final musicPlayer = Provider.of<MusicPlayerService>(context, listen: false);
          final userMusicService = Provider.of<UserMusicService>(context, listen: false);
          
          // Add to recently played
          userMusicService.addToRecentlyPlayed(song);
          
          // Set playlist with search results starting from this song
          musicPlayer.setPlaylist(_searchResults, startIndex: index);
          
          // Navigate to now playing screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NowPlayingScreen(song: song),
            ),
          );
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.white,
      ),
    );
  }

  List<String> _getPopularArtists(List<Song> songs) {
    Map<String, int> artistCount = {};
    for (var song in songs) {
      artistCount[song.artist] = (artistCount[song.artist] ?? 0) + 1;
    }
    
    var sortedArtists = artistCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedArtists.take(6).map((e) => e.key).toList();
  }
}