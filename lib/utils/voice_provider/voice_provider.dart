import 'package:flutter/foundation.dart';
import 'voice_engine.dart';

class VoiceProvider extends ChangeNotifier {
  final VoiceEngine _engine = VoiceEngine();
  bool _isSpeaking = false;

  bool get isSpeaking => _isSpeaking;

  VoiceProvider() {
    _engine.onStart = () {
      _isSpeaking = true;
      notifyListeners();
    };
    _engine.onStop = () {
      _isSpeaking = false;
      notifyListeners();
    };
    _engine.init();
  }

  Future<void> speak(String text, String lang) async {
    await _engine.speak(text, lang);
  }

  Future<void> stop() async {
    await _engine.stop();
  }
}