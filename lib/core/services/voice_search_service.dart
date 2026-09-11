import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

// ─────────────────────────────────────────────────────────────────────────────
// VoiceSearchState — all possible states of the voice recognition pipeline
// ─────────────────────────────────────────────────────────────────────────────

enum VoiceSearchState {
  idle,
  listening,
  processing,
  result,
  error,
  permissionDenied,
  unavailable,
}

// ─────────────────────────────────────────────────────────────────────────────
// VoiceSearchService
//
// Wrapper around the speech_to_text package for BiliRoute voice-assisted search.
//
// Architecture:
//   VoiceSearchService (ChangeNotifier)
//         ↓
//   SpeechToText (package)
//         ↓
//   Android SpeechRecognizer
//
// The recognized text is delivered via [onResult] callback so it can be
// injected into the EXISTING search pipeline without duplicating search logic.
//
// Language:
//   Accepts an optional [localeId] so the recognizer can be hinted to
//   the user's selected app language (e.g. 'es-ES' for Spanish).
//   Falls back gracefully if the language pack is not installed.
// ─────────────────────────────────────────────────────────────────────────────

class VoiceSearchService extends ChangeNotifier {
  final SpeechToText _speech = SpeechToText();

  VoiceSearchState _state           = VoiceSearchState.idle;
  String           _recognizedText  = '';
  String           _errorMessage    = '';
  bool             _initialized     = false;

  // ── Getters ────────────────────────────────────────────────────────────────

  VoiceSearchState get state          => _state;
  String           get recognizedText => _recognizedText;
  String           get errorMessage   => _errorMessage;
  bool             get isListening    => _state == VoiceSearchState.listening;

  /// Returns true if speech recognition is available and initialized.
  bool get isAvailable => _initialized && _speech.isAvailable;

  // ── Initialization ─────────────────────────────────────────────────────────

  /// Initialize the speech recognizer. Must be called before [startListening].
  /// Returns true if the device supports speech recognition.
  Future<bool> initialize() async {
    if (_initialized) return isAvailable;

    try {
      final available = await _speech.initialize(
        onError: _onSpeechError,
        onStatus: _onSpeechStatus,
      );
      _initialized = true;

      if (!available) {
        _setState(VoiceSearchState.unavailable);
      }
      return available;
    } catch (e) {
      _initialized = true;
      _setState(VoiceSearchState.unavailable);
      return false;
    }
  }

  // ── Start Listening ────────────────────────────────────────────────────────

  /// Begin voice recognition.
  ///
  /// [onResult] — called each time the recognizer produces finalized text.
  ///              This text should be fed into the existing search pipeline.
  ///
  /// [localeId] — optional BCP 47 language tag (e.g. 'es-ES', 'en-US').
  ///              Passed as a hint; falls back gracefully if unsupported.
  Future<void> startListening({
    required void Function(String text) onResult,
    String? localeId,
  }) async {
    // Ensure initialized
    final ready = await initialize();
    if (!ready) {
      _setError('Voice search is not available on this device.');
      _setState(VoiceSearchState.unavailable);
      return;
    }

    // Stop any ongoing session first
    if (_speech.isListening) {
      await _speech.stop();
    }

    _recognizedText = '';
    _setState(VoiceSearchState.listening);

    await _speech.listen(
      onResult: (result) {
        _recognizedText = result.recognizedWords;
        notifyListeners();

        if (result.finalResult && _recognizedText.isNotEmpty) {
          _setState(VoiceSearchState.result);
          onResult(_recognizedText);
        }
      },
      listenOptions: SpeechListenOptions(
        listenFor:      const Duration(seconds: 15),
        pauseFor:       const Duration(seconds: 4),
        localeId:       localeId,
        partialResults: true,
        cancelOnError:  true,
        listenMode:     ListenMode.search,
      ),
    );
  }

  // ── Stop Listening ─────────────────────────────────────────────────────────

  /// Manually stop voice recognition (e.g., user taps mic button again).
  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
    if (_state == VoiceSearchState.listening) {
      _setState(VoiceSearchState.idle);
    }
  }

  // ── Cancel ────────────────────────────────────────────────────────────────

  /// Cancel recognition without producing a result.
  Future<void> cancel() async {
    if (_speech.isListening) {
      await _speech.cancel();
    }
    _recognizedText = '';
    _setState(VoiceSearchState.idle);
  }

  // ── Reset ──────────────────────────────────────────────────────────────────

  /// Reset to idle state.
  void reset() {
    _recognizedText = '';
    _errorMessage   = '';
    _setState(VoiceSearchState.idle);
  }

  // ── Private callbacks ──────────────────────────────────────────────────────

  void _onSpeechStatus(String status) {
    debugPrint('[VoiceSearch] Status: $status');

    switch (status) {
      case 'listening':
        _setState(VoiceSearchState.listening);
        break;
      case 'notListening':
      case 'done':
        if (_state == VoiceSearchState.listening) {
          // If no final result was produced, check if we got something
          if (_recognizedText.isEmpty) {
            _setState(VoiceSearchState.idle);
          }
        }
        break;
    }
  }

  void _onSpeechError(dynamic error) {
    debugPrint('[VoiceSearch] Error: $error');

    final errorString = error.toString();
    String userMessage;

    if (errorString.contains('permission')) {
      userMessage = 'Microphone permission is required for voice search.';
      _setState(VoiceSearchState.permissionDenied);
    } else if (errorString.contains('no_match') ||
               errorString.contains('speech_timeout')) {
      userMessage = 'No speech detected. Please try again.';
      _setState(VoiceSearchState.idle);
    } else {
      userMessage = 'Voice search encountered an error. Please try again.';
      _setState(VoiceSearchState.error);
    }

    _errorMessage = userMessage;
    notifyListeners();
  }

  void _setState(VoiceSearchState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }
}
