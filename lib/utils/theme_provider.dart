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
  const AppTheme({
    required this.id,
    required this.name,
    required this.emoji,
    required this.primary,
    required this.background,
    required this.card,
    required this.cardLight,
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
    ),
    AppTheme(
      id: 'midnight_cyan',
      name: 'Midnight & Cyan',
      emoji: '⚡',
      primary: Color(0xFF00E5FF),
      background: Color(0xFF050508),
      card: Color(0xFF0D0D14),
      cardLight: Color(0xFF161622),
    ),
    AppTheme(
      id: 'ocean_green',
      name: 'Ocean Green',
      emoji: '🌊',
      primary: Color(0xFF00C896),
      background: Color(0xFF021A12),
      card: Color(0xFF052E1E),
      cardLight: Color(0xFF0A4A30),
    ),
    AppTheme(
      id: 'deep_blue',
      name: 'Deep Blue',
      emoji: '🌀',
      primary: Color(0xFF4488FF),
      background: Color(0xFF030A1A),
      card: Color(0xFF081428),
      cardLight: Color(0xFF102040),
    ),
    AppTheme(
      id: 'coral_sunset',
      name: 'Coral Sunset',
      emoji: '🌅',
      primary: Color(0xFFFF6B6B),
      background: Color(0xFF1A0A0A),
      card: Color(0xFF2A1010),
      cardLight: Color(0xFF3A1818),
    ),
  ];
}

class ThemeProvider extends ChangeNotifier {
  String _currentThemeId = 'navy_gold';

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