import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  String get currentCode => _locale.languageCode;

  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English', 'native': 'English',  'flag': '🇬🇧'},
    {'code': 'hi', 'name': 'Hindi',   'native': 'हिन्दी',   'flag': '🇮🇳'},
    {'code': 'ta', 'name': 'Tamil',   'native': 'தமிழ்',    'flag': '🇮🇳'},
    {'code': 'te', 'name': 'Telugu',  'native': 'తెలుగు',   'flag': '🇮🇳'},
    {'code': 'ar', 'name': 'Arabic',  'native': 'العربية',  'flag': '🇦🇪'},
    {'code': 'fr', 'name': 'French',  'native': 'Français', 'flag': '🇫🇷'},
  ];

  // ── Load: SharedPreferences first (instant), Firestore silently after ────────
  Future<void> loadFromFirestore() async {
    // 1. Read local cache immediately — zero wait
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('lang');
      if (cached != null && cached.isNotEmpty) {
        _locale = Locale(cached);
        notifyListeners();
      }
    } catch (_) {}

    // 2. Sync from Firestore silently in background
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final lang = doc.data()?['language'] as String?;
      if (lang != null && lang.isNotEmpty && lang != currentCode) {
        _locale = Locale(lang);
        notifyListeners();
        // Keep local cache in sync
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('lang', lang);
      }
    } catch (_) {}
  }

  void setLanguage(String code) {
    if (code == currentCode) return;
    _locale = Locale(code);
    notifyListeners();
    _persist(code);
  }

  Future<void> _persist(String code) async {
    // Write locally first — never blocks UI
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lang', code);
    } catch (_) {}
    // Then sync to Firestore
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'language': code}, SetOptions(merge: true));
    } catch (_) {}
  }

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