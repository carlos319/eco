import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Servicio central de voz (TTS) de la app.
///
/// Usa la voz en español del sistema (no requiere archivos de audio).
/// La velocidad es lenta, pensada para niños que aprenden a leer.
///
/// Nota web: en Chrome algunos métodos de configuración no existen;
/// se protegen uno a uno para que un fallo no desactive la voz.
class TtsService {
  TtsService._();

  static final TtsService instance = TtsService._();

  FlutterTts? _tts;
  bool _ready = false;

  /// Velocidades de habla.
  static const double rateNormal = 0.45;
  static const double rateSlow = 0.32;
  static const double rateSentence = 0.5;

  Future<FlutterTts?> _engine() async {
    if (_ready) return _tts;
    _ready = true;
    try {
      final tts = FlutterTts();
      // Configuración protegida método a método: en algunas
      // plataformas un método puede no existir y no debe tumbar el motor.
      try {
        await tts.setLanguage('es-ES');
      } catch (_) {}
      try {
        await tts.setSpeechRate(rateNormal);
      } catch (_) {}
      try {
        await tts.setPitch(1.05);
      } catch (_) {}
      try {
        await tts.setVolume(1.0);
      } catch (_) {}
      try {
        await tts.awaitSpeakCompletion(true);
      } catch (_) {}
      if (!kIsWeb) {
        // Motor de cola: solo Android.
        try {
          await tts.setQueueMode(1);
        } catch (_) {}
      }
      _tts = tts;
      return tts;
    } catch (_) {
      // Sin TTS disponible: la app sigue funcionando en silencio.
      _tts = null;
      return null;
    }
  }

  /// Inicializa el motor de TTS (se llama al arrancar la app).
  Future<void> ensureInit() async {
    await _engine();
  }

  /// Pronuncia [text] a velocidad normal para sílabas/palabras.
  Future<void> speak(String text) => _speakWith(text, rateNormal);

  /// Pronuncia [text] muy despacio (letras y sílabas nuevas).
  Future<void> speakSlow(String text) => _speakWith(text, rateSlow);

  /// Pronuncia [text] a velocidad de frase.
  Future<void> speakSentence(String text) => _speakWith(text, rateSentence);

  Future<void> _speakWith(String text, double rate) async {
    final tts = await _engine();
    if (tts == null) return;
    try {
      await tts.setSpeechRate(rate);
    } catch (_) {}
    try {
      await tts.speak(text);
    } catch (_) {}
  }

  /// Detiene cualquier habla en curso.
  Future<void> stop() async {
    final tts = _tts;
    if (tts == null) return;
    try {
      await tts.stop();
    } catch (_) {}
  }
} 