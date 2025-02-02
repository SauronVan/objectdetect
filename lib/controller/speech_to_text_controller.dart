import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/material.dart';

class SpeechToTextController with ChangeNotifier {
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  bool _isCameraActive = false;
  String _recognizedText = "Press the button to start speaking";
  String _selectedLanguage = 'en_US';
  List<stt.LocaleName> _availableLanguages = [];

  SpeechToTextController() {
    _speechToText = stt.SpeechToText();
    _loadAvailableLanguages();
  }

  String get recognizedText => _recognizedText;
  String get selectedLanguage => _selectedLanguage;
  bool get isListening => _isListening;
  bool get isCameraActive => _isCameraActive;
  List<stt.LocaleName> get availableLanguages => _availableLanguages;

  // Load available languages
  Future<void> _loadAvailableLanguages() async {
    final locales = await _speechToText.locales();
    _availableLanguages = locales;
    if (_availableLanguages.isNotEmpty) {
      _selectedLanguage = _availableLanguages[0].localeId;
    }
    notifyListeners();
  }

  // Toggle Listening
  Future<void> toggleListening() async {
    if (_isListening) {
      _speechToText.stop();
      _isListening = false;
      _recognizedText = "Press the button to start speaking";
    } else {
      final available = await _speechToText.initialize();
      if (available) {
        _isListening = true;
        _recognizedText = "Listening...";
        _speechToText.listen(
          localeId: _selectedLanguage,
          onResult: (result) {
            _recognizedText = result.recognizedWords;
            notifyListeners();
          },
        );
      } else {
        _recognizedText = "Unable to connect to the microphone.";
      }
    }
    notifyListeners();
  }

  // Toggle Camera
  void toggleCamera() {
    _isCameraActive = !_isCameraActive;
    notifyListeners();
  }

  // Set the selected language
  void setSelectedLanguage(String language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  // Dispose of resources
  void dispose() {
    if (_isListening) {
      _speechToText.stop();
    }
    super.dispose();
  }
}
