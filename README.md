# Music Streaming App

A Flutter music streaming application using the Deezer API for searching and playing music.

## Features

- Modern splash screen with animations
- User authentication (login/signup)
- Search for songs, artists, and albums using Deezer API
- Music player with playback controls
- Album art display
- Progress bar with seek functionality

## How to Use

1. Launch the app to see the splash screen
2. Login with any credentials (for demo purposes)
3. Search for music using the search bar
4. Tap the play button on any track to start playback
5. Use the player controls to play/pause music

## Getting a Deezer API Key

To use the full functionality of this app, you need to register for a Deezer Developer API key:

1. Go to [Deezer Developers](https://developers.deezer.com/)
2. Click "Login" and sign in with your Deezer account (or create one)
3. Click "My Apps" in the top navigation
4. Click "Create a new Application"
5. Fill in the application details:
   - Name: Music Streaming App (or any name you prefer)
   - Description: A Flutter music streaming application
   - Website: (You can put any URL, like https://example.com)
   - Terms of Use: Check the box
6. Click "Create Application"
7. Copy your "Application ID" (not the secret key)

## Setting Up Your API Key

1. Open `lib/config.dart` in your project
2. Replace the empty string in `deezerAppId` with your Application ID:
   ```dart
   static const String deezerAppId = 'YOUR_APPLICATION_ID_HERE';
   ```
3. Save the file

## Technical Details

- Uses Deezer API for music search (API key recommended for full functionality)
- Implements just_audio package for music playback
- 30-second previews provided by Deezer
- Clean, modern UI with deep purple theme

## Dependencies

- `http` - For API requests to Deezer
- `just_audio` - For music playback
- `audio_session` - For audio session management

## Project Structure

- `lib/models/` - Data models (Track)
- `lib/services/` - Business logic (API service, music player service)
- `lib/screens/` - UI screens (Search, Music Player)
- `lib/` - Main app files (login, signup, splash screen)

## How It Works

The app makes HTTP GET requests to Deezer's API endpoints. The responses are JSON objects containing track information including:
- Track title
- Artist name
- Album title
- Album cover image URL
- 30-second preview URL

The just_audio package handles playing the preview URLs directly from Deezer's servers.