import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppTheme {
  final String id;
  final String name;
  final String emoji;
  final Color primary;
  final Color background;
  final Color card;
  final Color cardLight;
  final String backgroundImage;

  const AppTheme({
    required this.id,
    required this.name,
    required this.emoji,
    required this.primary,
    required this.background,
    required this.card,
    required this.cardLight,
    required this.backgroundImage,
  });

  static const List<AppTheme> themes = [
    AppTheme(
      id: 'navy_gold',
      name: 'Navy & Gold',
      emoji: '⚓',
      primary: Color(0xFFF4A532),
      background: Color(0xFF060F1E),
      card: Color(0xFF0D2240),
      cardLight: Color(0xFF1A3A5C),
      backgroundImage:
          'https://images.unsplash.com/photo-1505118380757-91f5f5632de0?w=800',
    ),
    AppTheme(
      id: 'midnight_cyan',
      name: 'Midnight & Cyan',
      emoji: '⚡',
      primary: Color(0xFF00E5FF),
      background: Color(0xFF050508),
      card: Color(0xFF0D0D14),
      cardLight: Color(0xFF161622),
      backgroundImage:
          'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800',
    ),
    AppTheme(
      id: 'ocean_green',
      name: 'Ocean Green',
      emoji: '🌊',
      primary: Color(0xFF00C896),
      background: Color(0xFF021A12),
      card: Color(0xFF052E1E),
      cardLight: Color(0xFF0A4A30),
      backgroundImage:
          'https://images.unsplash.com/photo-1505142468610-359e7d316be0?w=800',
    ),
    AppTheme(
      id: 'deep_blue',
      name: 'Deep Blue',
      emoji: '🌀',
      primary: Color(0xFF4488FF),
      background: Color(0xFF030A1A),
      card: Color(0xFF081428),
      cardLight: Color(0xFF102040),
      backgroundImage:
          'https://images.unsplash.com/photo-1518020382113-a7e8fc38eac9?w=800',
    ),
    AppTheme(
      id: 'coral_sunset',
      name: 'Coral Sunset',
      emoji: '🌅',
      primary: Color(0xFFFF6B6B),
      background: Color(0xFF1A0A0A),
      card: Color(0xFF2A1010),
      cardLight: Color(0xFF3A1818),
      backgroundImage:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
    ),
  ];
}

class ThemeProvider extends ChangeNotifier {
  String _currentThemeId = 'navy_gold';

  // Exposing the themes list so tp.themes works in the screen
  List<AppTheme> get themes => AppTheme.themes;

  AppTheme get current => AppTheme.themes.firstWhere(
        (t) => t.id == _currentThemeId,
        orElse: () => AppTheme.themes.first,
      );

  String get currentThemeId => _currentThemeId;

  void setTheme(String themeId) {
    if (_currentThemeId == themeId) return;
    _currentThemeId = themeId;
    notifyListeners();
    _saveThemeToFirestore(themeId);
  }

  Future<void> loadThemeFromFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final themeId = doc.data()?['theme'] as String?;
      if (themeId != null && themeId != _currentThemeId) {
        _currentThemeId = themeId;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _saveThemeToFirestore(String themeId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'theme': themeId}, SetOptions(merge: true));
    } catch (_) {}
  }
}