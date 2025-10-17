import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../models/song.dart';
import '../services/songs_provider.dart';

class AddSongScreen extends StatefulWidget {
  const AddSongScreen({super.key});

  @override
  State<AddSongScreen> createState() => _AddSongScreenState();
}

class _AddSongScreenState extends State<AddSongScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _albumController = TextEditingController();
  final _durationController = TextEditingController();
  final _urlController = TextEditingController();
  final _coverArtController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    _durationController.dispose();
    _urlController.dispose();
    _coverArtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Song'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Song title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Song Title',
                  prefixIcon: Icon(Icons.music_note),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a song title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Artist field
              TextFormField(
                controller: _artistController,
                decoration: const InputDecoration(
                  labelText: 'Artist',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an artist name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Album field
              TextFormField(
                controller: _albumController,
                decoration: const InputDecoration(
                  labelText: 'Album',
                  prefixIcon: Icon(Icons.album),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an album name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Duration field
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (MM:SS)',
                  prefixIcon: Icon(Icons.timer),
                ),
                inputFormatters: [
                  // Format duration as MM:SS while typing
                  LengthLimitingTextInputFormatter(5),
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the duration';
                  }
                  // Basic validation for MM:SS format
                  if (!RegExp(r'^\d{1,2}:\d{2}$').hasMatch(value)) {
                    return 'Please enter duration in MM:SS format';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // URL field (for audio file path)
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Audio File Path',
                  prefixIcon: Icon(Icons.link),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the audio file path';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Cover art URL field
              TextFormField(
                controller: _coverArtController,
                decoration: const InputDecoration(
                  labelText: 'Cover Art Path (Optional)',
                  prefixIcon: Icon(Icons.image),
                ),
              ),
              const SizedBox(height: 32),
              
              // Add song button
              ElevatedButton(
                onPressed: _addSong,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Add Song',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addSong() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Create a new song
        final song = Song(
          title: _titleController.text.trim(),
          artist: _artistController.text.trim(),
          album: _albumController.text.trim(),
          duration: _durationController.text.trim(),
          url: _urlController.text.trim(),
          coverArt: _coverArtController.text.trim().isNotEmpty 
              ? _coverArtController.text.trim() 
              : null,
        );

        // Add to provider
        final songsProvider = Provider.of<SongsProvider>(context, listen: false);
        await songsProvider.addSong(song);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Song added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Clear form
          _titleController.clear();
          _artistController.clear();
          _albumController.clear();
          _durationController.clear();
          _urlController.clear();
          _coverArtController.clear();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding song: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}