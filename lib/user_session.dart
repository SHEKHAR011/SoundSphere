import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/firebase_service.dart';

class UserSession extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoggedIn = false;
  String _userName = '';
  String _userEmail = '';

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userEmail => _userEmail;

  UserSession() {
    // Listen to authentication state changes
    _firebaseService.authStateChanges.listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) {
    if (user != null) {
      _isLoggedIn = true;
      _userName = user.displayName ?? user.email ?? '';
      _userEmail = user.email ?? '';
    } else {
      _isLoggedIn = false;
      _userName = '';
      _userEmail = '';
    }
    notifyListeners();
  }

  Future<bool> loginWithEmail(String email, String password) async {
    UserCredential? result = 
        await _firebaseService.signInWithEmailAndPassword(email, password);
    
    if (result != null) {
      _isLoggedIn = true;
      _userEmail = result.user!.email ?? '';
      _userName = result.user!.displayName ?? result.user!.email ?? '';
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> signUpWithEmail(String email, String password, String name) async {
    UserCredential? result = 
        await _firebaseService.signUpWithEmailAndPassword(email, password);
    
    if (result != null) {
      // Update display name
      await result.user!.updateDisplayName(name);
      _isLoggedIn = true;
      _userEmail = result.user!.email ?? '';
      _userName = name;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await _firebaseService.signOut();
    _isLoggedIn = false;
    _userName = '';
    _userEmail = '';
    notifyListeners();
  }
}