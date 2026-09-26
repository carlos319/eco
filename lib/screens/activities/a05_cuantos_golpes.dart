import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/activity.dart';
import '../../services/audio_service.dart';
import '../../services/tts_service.dart';
import '../../widgets/activity/activity_host.dart';
import '../../widgets/activity/big_card.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';

/// A05 · ¿Cuántos golpes? — conciencia silábica con el tambor.
class A05CuantosGolpes extends StatelessWidget {
  const A05CuantosGolpes({super.key, required this.spec});

  final ActivitySpec spec;

  static const List<_Round> _rounds = [
    _Round(emoji: '🦆', word: 'pato', beats: 'pa, to', target: 2),
    _Round(emoji: '🐢', word: 'tortuga', beats: 'tor, tu, ga', target: 3),
    _Round(emoji: '🐘', word: 'elefante', beats: 'e, le, fan, te', target: 4),
    _Round(emoji: '🌙', word: 'luna', beats: 'lu, na', target: 2),
    _Round(emoji: '🦋', word: 'mariposa', beats: 'ma, ri, po, sa', target: 4),
  ];

  @override
  Widget build(BuildContext context) {
    return ActivityHost(
      spec: spec,
      roundCount: _rounds.length,
      roundSpeech: (round) =>
          'Escucha: ${_rounds[round].beats}. ¡${_rounds[round].word}! '
          'Golpea el tambor una vez por cada parte.',
      roundBuilder: (context, round, controller) => _RoundView(
        key: ValueKey(round),
        round: _rounds[round],
        controller: controller,
      ),
    );
  }
}

class _Round {
  const _Round({
    required this.emoji,
    required this.word,
    required this.beats,
    required this.target,
  });

  final String emoji;
  final String word;
  final String beats;
  final int target;
}

class _RoundView extends StatefulWidget {
  const _RoundView({
    super.key,
    required this.round,
    required this.controller,
  });

  final _Round round;
  final ActivityController controller;

  @override
  State<_RoundView> createState() => _RoundViewState();
}

class _RoundViewState extends State<_RoundView> {
  int _count = 0;
  bool _solved = false;

  Future<void> _drumTap() async {
    if (_solved || _count >= widget.round.target) return;
    await AudioService.instance.drum();
    if (mounted) setState(() => _count += 1);
  }

  void _check() {
    if (_solved) return;
    if (_count == widget.round.target) {
      setState(() => _solved = true);
      widget.controller.roundCorrect(phrase: '¡Exacto! Esas eran.');
    } else {
      setState(() => _count = 0);
      widget.controller
          .roundWrong(phrase: 'Escucha otra vez y cuenta conmigo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final round = widget.round;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Palabra de la ronda + repetir.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BigCard(
              label: round.emoji,
              size: 110,
              color: 'green',
              state: _solved ? BigCardState.success : BigCardState.normal,
            ),
            const SizedBox(width: 16),
            SpeakerButton(
              onTap: () => TtsService.instance.speak(round.word),
              size: 56,
            ),
          ],
        ),
        // El tambor.
        GestureDetector(
          onTap: _drumTap,
          child: BigCard(
            label: '🥁',
            size: 140,
            color: 'yellow',
            state: _solved ? BigCardState.success : BigCardState.normal,
          ),
        ),
        // Golpes dados.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(round.target, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Icon(
                _solved || i < _count
                    ? Icons.circle
                    : Icons.circle_outlined,
                size: 22,
                color: AppPalette.orange,
              ),
            );
          }),
        ),
        BigButton(
          label: '¡Listo!',
          color: AppPalette.orange,
          icon: Icons.check_rounded,
          onPressed: _solved ? null : _check,
        ),
      ],
    );
  }
}