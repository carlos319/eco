import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'tts_service.dart';

/// Efectos de sonido disponibles (archivos en assets/audio/).
///
/// La carpeta assets/audio/ está pensada para reemplazarse después por
/// voces y efectos grabados reales; los nombres de archivo no cambian.
enum Sfx { success, error, pop, star, drum, tada }

/// Servicio central de audio de la app: voz (TTS) + efectos (WAV locales).
///
/// - La voz siempre sale por [TtsService] (español, lenta, para niños).
/// - Los efectos son WAV cortos en assets; si fallan (o no existen),
///   la app sigue funcionando en silencio.
/// - Funciona sin internet: todo es local.
class AudioService {
  AudioService._();

  static final AudioService instance = AudioService._();

  static const _files = {
    Sfx.success: 'success.wav',
    Sfx.error: 'error.wav',
    Sfx.pop: 'pop.wav',
    Sfx.star: 'star.wav',
    Sfx.drum: 'drum.wav',
    Sfx.tada: 'tada.wav',
  };

  final Map<Sfx, AudioPlayer> _players = {};

  bool _ready = false;

  /// Prepara los reproductores (se llama al arrancar la app).
  Future<void> ensureInit() async {
    if (_ready) return;
    _ready = true;
    if (kIsWeb) return; // en web se crean bajo demanda igualmente
    for (final sfx in Sfx.values) {
      _playerFor(sfx);
    }
  }

  AudioPlayer _playerFor(Sfx sfx) {
    return _players.putIfAbsent(sfx, () {
      final player = AudioPlayer(playerId: 'ec0_${sfx.name}');
      // Todos los efectos comparten el mismo volumen (fondo de la voz).
      player.setReleaseMode(ReleaseMode.stop);
      player.setVolume(0.9);
      return player;
    });
  }

  /// Reproduce un efecto de sonido sin bloquear la interfaz.
  Future<void> play(Sfx sfx) async {
    final player = _playerFor(sfx);
    try {
      await player.stop();
      await player.play(AssetSource('audio/${_files[sfx]}'));
    } catch (_) {
      // Silencio intencional: sin el asset o sin audio disponible,
      // una partida infantil jamás debe romperse por un error de sonido.
      return;
    }
  }

  // ------------------------------------------------- atajos voz + sonido

  /// Acierto: música alegre + voz de celebración.
  Future<void> cheer({String phrase = '¡Muy bien!'}) async {
    await play(Sfx.success);
    await TtsService.instance.speakSentence(phrase);
  }

  /// Error suave: boop grave + frase amable para reintentar.
  Future<void> gentleRetry({String phrase = 'Inténtalo otra vez'}) async {
    await play(Sfx.error);
    await TtsService.instance.speakSentence(phrase);
  }

  /// Estrella ganada.
  Future<void> star({String? phrase}) async {
    await play(Sfx.star);
    if (phrase != null) await TtsService.instance.speakSentence(phrase);
  }

  /// Golpe de tambor (sílabas de A05).
  Future<void> drum() => play(Sfx.drum);

  /// Pequeño toque al soltar o colocar piezas.
  Future<void> pop() => play(Sfx.pop);

  /// Celebración final de actividad.
  Future<void> fanfare({String phrase = '¡Lo lograste! Eres genial.'}) async {
    await play(Sfx.tada);
    await TtsService.instance.speakSentence(phrase);
  }
}