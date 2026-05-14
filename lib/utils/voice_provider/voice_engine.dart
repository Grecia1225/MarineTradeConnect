// Web implementation of VoiceEngine using browser's speechSynthesis
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

class VoiceEngine {
  Function()? onStart;
  Function()? onStop;

  void init() {}

  Future<void> speak(String text, String lang) async {
    try {
      js.context.callMethod('eval', ['''
        window.speechSynthesis.cancel();
        var u = new SpeechSynthesisUtterance("$text");
        u.lang = "$lang";
        u.rate = 0.88;
        u.pitch = 1.0;
        u.volume = 1.0;
        window.speechSynthesis.speak(u);
      ''']);
      onStart?.call();
    } catch (_) {
      onStop?.call();
    }
  }

  Future<void> stop() async {
    try {
      js.context.callMethod('eval', ['window.speechSynthesis.cancel();']);
    } catch (_) {}
    onStop?.call();
  }
}