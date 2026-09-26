import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_theme.dart';
import '../../models/activity.dart';
import '../../services/audio_service.dart';
import '../../services/progress_service.dart';
import '../../services/tts_service.dart';
import '../buttons.dart';
import '../feedback.dart';
import 'guide_bubble.dart';
import 'star_header.dart';
import 'stars_row.dart';

/// Controlador que una actividad usa para responder al niño.
///
/// Encapsula estrellas, avance de rondas, sonidos, voz y guardado de
/// progreso, para que cada actividad solo escriba su mecánica.
class ActivityController {
  ActivityController(this._state);

  final _ActivityHostState _state;

  /// Ronda actual (0-based).
  int get round => _state._round;

  /// Estrellas ganadas en esta sesión (0-5).
  int get stars => _state._stars;

  /// Especificación de la actividad en curso.
  ActivitySpec get spec => _state.widget.spec;

  /// Vuelve a leer la instrucción de la actividad o de la ronda.
  Future<void> repeatInstruction() =>
      _state._speakCurrent(showBubble: true);

  /// Ronda superada: +1 estrella, celebración y avanza.
  ///
  /// [phrase] es la voz alegre (por defecto "¡Muy bien!").
  Future<void> roundCorrect({String? phrase}) =>
      _state._onRoundCorrect(phrase: phrase);

  /// Respuesta incorrecta: error suave (vibración corta + voz amable).
  Future<void> roundWrong({String? phrase}) =>
      _state._onRoundWrong(phrase: phrase);

  /// Estrella extra sin avanzar ronda (actividades por gestos, como A03).
  Future<void> bonusStar({String? phrase}) =>
      _state._awardStar(phrase: phrase, advance: false);

  /// Termina la actividad desde ya (por logros acumulados).
  Future<void> finishEarly() => _state._finish();

  /// Anuncia texto por voz sin tocar el flujo de estrellas.
  Future<void> say(String text) => TtsService.instance.speakSentence(text);
}

/// Andamiaje común de las 15 actividades de Iniciación.
///
/// Provee: cabecera con estrellas (⭐ x/5), personaje guía con burbuja,
/// voz de instrucciones, celebración por ronda, error suave y
/// celebración final con regreso al mapa.
class ActivityHost extends StatefulWidget {
  const ActivityHost({
    super.key,
    required this.spec,
    required this.roundCount,
    required this.roundBuilder,
    this.roundSpeech,
    this.speakRoundSpeechForFirst = true,
  });

  /// Actividad actual (título, emoji, instrucción inicial).
  final ActivitySpec spec;

  /// Número total de rondas (normalmente 5).
  final int roundCount;

  /// Construye el contenido de la ronda [round].
  final Widget Function(BuildContext, int round, ActivityController)
      roundBuilder;

  /// Voz opcional al empezar cada ronda.
  final String Function(int round)? roundSpeech;

  /// Si la voz de la ronda 0 se dice además de la instrucción general.
  final bool speakRoundSpeechForFirst;

  @override
  State<ActivityHost> createState() => _ActivityHostState();
}

class _ActivityHostState extends State<ActivityHost> {
  int _round = 0;
  int _stars = 0;
  bool _roundBusy = false; // bloquea toques durante la celebración
  bool _finished = false;
  String _bubble = '';
  late final ActivityController controller;

  @override
  void initState() {
    super.initState();
    controller = ActivityController(this);
    _bubble = widget.spec.instruction;
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _startRound(first: true));
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }

  Future<void> _startRound({bool first = false}) async {
    if (_finished) return;
    final speech = widget.roundSpeech?.call(_round);
    if (first) {
      await _speakCurrent(
        showBubble: true,
        alsoRoundSpeech: speech != null && widget.speakRoundSpeechForFirst,
        roundSpeech: speech,
      );
    } else {
      // Rondas siguientes: solo la voz propia de la ronda.
      if (speech != null) {
        if (mounted) setState(() => _bubble = speech);
        await TtsService.instance.speakSentence(speech);
      }
    }
  }

  Future<void> _speakCurrent({
    bool showBubble = false,
    bool alsoRoundSpeech = false,
    String? roundSpeech,
  }) async {
    if (showBubble && mounted) {
      setState(() => _bubble = widget.spec.instruction);
    }
    await TtsService.instance.speakSentence(widget.spec.instruction);
    if (alsoRoundSpeech && roundSpeech != null) {
      if (showBubble && mounted) setState(() => _bubble = roundSpeech);
      await TtsService.instance.speakSentence(roundSpeech);
    }
  }

  Future<void> _onRoundCorrect({String? phrase}) async {
    if (_roundBusy || _finished) return;
    _roundBusy = true;
    await _awardStar(phrase: phrase, advance: true);
    _roundBusy = false;
  }

  Future<void> _awardStar({String? phrase, bool advance = true}) async {
    if (_finished) return;
    _stars = (_stars + 1).clamp(0, 5);
    await ProgressService.instance.saveActivityStars(widget.spec.id, _stars);
    if (mounted) setState(() {});
    await AudioService.instance.cheer(phrase: phrase ?? '¡Muy bien!');
    if (_stars == 5) {
      await _finish();
      return;
    }
    if (advance) {
      if (_round + 1 < widget.roundCount) {
        _round += 1;
        if (mounted) setState(() {});
        await _startRound();
      } else {
        // Rondas agotadas sin llegar a 5: celebrar igual.
        await _finish();
      }
    }
  }

  Future<void> _onRoundWrong({String? phrase}) async {
    if (_roundBusy || _finished) return;
    HapticFeedback.mediumImpact();
    await AudioService.instance
        .gentleRetry(phrase: phrase ?? 'Inténtalo otra vez');
  }

  Future<void> _finish() async {
    if (_finished) return;
    _finished = true;
    await AudioService.instance.fanfare();
    if (mounted) setState(() {});
  }

  void _goBackToMap() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  // ------------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.cream,
      body: SafeArea(child: _finished ? _buildFinal() : _buildPlaying()),
    );
  }

  Widget _buildPlaying() {
    return Column(
      children: [
        StarHeader(
          spec: widget.spec,
          stars: _stars,
          total: 5,
          onBack: _goBackToMap,
          onRepeat: controller.repeatInstruction,
        ),
        GuideBubble(text: _bubble),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: widget.roundBuilder(context, _round, controller),
          ),
        ),
      ],
    );
  }

  Widget _buildFinal() {
    return Celebration(
      child: Column(
        children: [
          StarHeader(
            spec: widget.spec,
            stars: _stars,
            total: 5,
            onBack: _goBackToMap,
            onRepeat: controller.repeatInstruction,
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 90)),
                  const SizedBox(height: 8),
                  Text(
                    '¡LO LOGRASTE!',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: AppPalette.green,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ActivityStarsRow(stars: _stars, total: 5, size: 34),
                  const SizedBox(height: 26),
                  BigButton(
                    label: 'Al mapa',
                    color: AppPalette.sky,
                    icon: Icons.map_rounded,
                    onPressed: _goBackToMap,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}