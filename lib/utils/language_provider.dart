import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  // ✅ This is what dashboard_screen.dart calls
  String get currentCode => _locale.languageCode;

  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English', 'native': 'English',   'flag': '🇬🇧'},
    {'code': 'hi', 'name': 'Hindi',   'native': 'हिन्दी',    'flag': '🇮🇳'},
    {'code': 'ta', 'name': 'Tamil',   'native': 'தமிழ்',     'flag': '🇮🇳'},
    {'code': 'te', 'name': 'Telugu',  'native': 'తెలుగు',    'flag': '🇮🇳'},
    {'code': 'ar', 'name': 'Arabic',  'native': 'العربية',   'flag': '🇦🇪'},
    {'code': 'fr', 'name': 'French',  'native': 'Français',  'flag': '🇫🇷'},
  ];

  void setLanguage(String code) {
    _locale = Locale(code);
    notifyListeners();
    _saveToFirestore(code);
  }

  Future<void> loadFromFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final lang = doc.data()?['language'] as String?;
      if (lang != null && lang.isNotEmpty) {
        _locale = Locale(lang);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _saveToFirestore(String code) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'language': code}, SetOptions(merge: true));
    } catch (_) {}
  }

  // ✅ Fixed — uses currentCode (this class's own getter), not lang.currentCode
  String get currentLanguageName =>
      supportedLanguages.firstWhere(
        (l) => l['code'] == currentCode,
        orElse: () => supportedLanguages[0],
      )['name'] ?? 'English';

  String get currentFlag =>
      supportedLanguages.firstWhere(
        (l) => l['code'] == currentCode,
        orElse: () => supportedLanguages[0],
      )['flag'] ?? '🇬🇧';
}