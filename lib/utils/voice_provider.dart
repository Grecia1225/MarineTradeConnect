import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

class VoiceProvider extends ChangeNotifier {
  bool _isSpeaking = false;
  bool get isSpeaking => _isSpeaking;

  static bool get isSupported {
    try {
      return js.context.hasProperty('speechSynthesis');
    } catch (_) {
      return false;
    }
  }

  /// Speak any text in the given language
  Future<void> speak(String text, {String languageCode = 'en'}) async {
    if (!isSupported) return;
    try {
      final lang = _bcp47(languageCode);
      // Sanitise text — remove quotes that break JS eval
      final safe = text
          .replaceAll('"', '')
          .replaceAll("'", '')
          .replaceAll('\n', ' ')
          .replaceAll('\r', '');

      js.context.callMethod('eval', ['''
        window.speechSynthesis.cancel();
        var u = new SpeechSynthesisUtterance("$safe");
        u.lang  = "$lang";
        u.rate  = 0.88;
        u.pitch = 1.0;
        window.speechSynthesis.speak(u);
      ''']);

      _isSpeaking = true;
      notifyListeners();

      // Estimate duration then reset flag
      final secs = (safe.length / 12).ceil() + 2;
      await Future.delayed(Duration(seconds: secs));
      _isSpeaking = false;
      notifyListeners();
    } catch (_) {
      _isSpeaking = false;
      notifyListeners();
    }
  }

  /// Convenience method for reading a listing aloud
  Future<void> speakListing({
    required String title,
    required String price,
    required String quantity,
    required String location,
    required String seller,
    required String description,
    String languageCode = 'en',
  }) async {
    final Map<String, String> templates = {
      'en': '$title. Price $price. $quantity available. '
            'Location $location. Seller $seller. $description',
      'hi': '$title. कीमत $price. $quantity उपलब्ध. '
            'स्थान $location. विक्रेता $seller.',
      'ta': '$title. விலை $price. $quantity கிடைக்கும். '
            'இடம் $location. விற்பவர் $seller.',
      'ar': '$title. السعر $price. $quantity متاح. '
            'الموقع $location. البائع $seller.',
      'fr': '$title. Prix $price. $quantity disponible. '
            'Lieu $location. Vendeur $seller.',
      'te': '$title. ధర $price. $quantity అందుబాటులో ఉంది. '
            'స్థానం $location. విక్రేత $seller.',
    };
    final text = templates[languageCode] ?? templates['en']!;
    await speak(text, languageCode: languageCode);
  }

  Future<void> stop() async {
    if (!isSupported) return;
    try {
      js.context.callMethod('eval', ['window.speechSynthesis.cancel();']);
    } catch (_) {}
    _isSpeaking = false;
    notifyListeners();
  }

  static String _bcp47(String code) {
    const map = {
      'en': 'en-US',
      'hi': 'hi-IN',
      'ta': 'ta-IN',
      'te': 'te-IN',
      'ar': 'ar-SA',
      'fr': 'fr-FR',
    };
    return map[code] ?? 'en-US';
  }
}