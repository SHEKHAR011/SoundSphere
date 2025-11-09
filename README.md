# 🎶 SoundSphere

**SoundSphere** is an Android music application that allows users to securely log in using **Firebase Authentication** and play songs stored locally on their device.  
It provides a clean, modern interface for managing and enjoying music — all without the need for internet connectivity.

---

## 🚀 Features

- Modern splash screen with animations  
- Secure user authentication using **Firebase Auth** (Email & Password)  
- Automatic scanning of **local music files** from device storage  
- Full-featured **music player** with Play, Pause, Next, Previous, and Shuffle controls  
- **Album art** and **song information** display  
- **Persistent playback bar** visible across screens  
- Background playback with notification controls  
- Sleek **Material Design 3 (MD3)** interface  

---

## 📱 How to Use

1. Launch the app to view the splash screen  
2. **Sign up or log in** using Firebase Authentication  
3. After login, SoundSphere automatically scans your device for available songs  
4. Select any song from the library to start playback  
5. Use the bottom playback bar to **play/pause**, **skip**, or **shuffle** songs  
6. Enjoy your music even when the app is minimized — playback continues in the background  

---

## 🔧 Technical Overview

- Built with **Android Studio (Kotlin)**  
- Uses **Firebase Authentication** for secure user login  
- Reads and lists local music files using **MediaStore API**  
- Plays songs using **MediaPlayer API**  
- Stores user details and preferences in **Firebase Firestore**  
- Implements **ViewModel** and **LiveData** for reactive UI updates  

---

## 🧩 Dependencies

Add the following dependencies in your app-level `build.gradle` file:

```gradle
implementation 'com.google.firebase:firebase-auth:23.1.0'
implementation 'com.google.firebase:firebase-firestore:25.1.0'
implementation 'androidx.media:media:1.6.0'
implementation 'com.google.android.material:material:1.12.0'
implementation 'androidx.lifecycle:lifecycle-viewmodel-ktx:2.8.0'
