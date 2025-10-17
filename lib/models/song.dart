class Song {
  final int? id;
  final String title;
  final String artist;
  final String album;
  final String duration;
  final String url; // Path to the audio file
  final String? coverArt; // Path to the cover art image
  final DateTime dateAdded;

  Song({
    this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.url,
    this.coverArt,
    DateTime? dateAdded,
  }) : dateAdded = dateAdded ?? DateTime.now();

  // Convert a Song object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'duration': duration,
      'url': url,
      'coverArt': coverArt,
      'dateAdded': dateAdded.millisecondsSinceEpoch,
    };
  }

  // Create a Song object from a Map
  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'],
      title: map['title'] ?? '',
      artist: map['artist'] ?? '',
      album: map['album'] ?? '',
      duration: map['duration'] ?? '',
      url: map['url'] ?? '',
      coverArt: map['coverArt'],
      dateAdded: DateTime.fromMillisecondsSinceEpoch(map['dateAdded']),
    );
  }
}