import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  Future<bool> initialize() async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) return false;
    _isInitialized = await _speech.initialize();
    return _isInitialized;
  }

  Future<void> speakPrompt(String text, String languageCode) async {
    await _tts.setLanguage(languageCode);
    await _tts.setSpeechRate(0.45);
    await _tts.speak(text);
    await _tts.awaitSpeakCompletion(true);
  }

  Future<void> startListening({
    required Function(String text) onResult,
    required Function() onDone,
    String localeId = 'en_US',
  }) async {
    if (!_isInitialized) return;
    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
        if (result.finalResult) onDone();
      },
      localeId: localeId,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
    );
  }

  Future<void> stopListening() async => await _speech.stop();

  bool get isListening => _speech.isListening;
}