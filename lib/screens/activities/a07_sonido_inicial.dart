import 'package:flutter/material.dart';

import '../../models/activity.dart';
import '../../services/tts_service.dart';
import '../../widgets/activity/activity_host.dart';
import '../../widgets/activity/big_card.dart';
import '../../widgets/common.dart';

/// A07 · Sonido inicial y final — aislar el primer y último sonido.
class A07SonidoInicial extends StatelessWidget {
  const A07SonidoInicial({super.key, required this.spec});

  final ActivitySpec spec;

  static const List<_Round> _rounds = [
    _Round(emoji: '🐘', word: 'elefante', askFinal: false, sound: 'e', options: ['e', 'm', 'u']),
    _Round(emoji: '🐟', word: 'pez', askFinal: false, sound: 'p', options: ['p', 't', 'n']),
    _Round(emoji: '☀️', word: 'sol', askFinal: false, sound: 's', options: ['s', 'l', 'b']),
    _Round(emoji: '🦆', word: 'pato', askFinal: true, sound: 'o', options: ['o', 'a', 'e']),
    _Round(emoji: '🐭', word: 'ratón', askFinal: true, sound: 'n', options: ['n', 'm', 'r']),
  ];

  @override
  Widget build(BuildContext context) {
    return ActivityHost(
      spec: spec,
      roundCount: _rounds.length,
      roundSpeech: (round) {
        final r = _rounds[round];
        return r.askFinal
            ? 'Escucha: ${r.word}. ¿Con qué sonido termina? Toca la letra.'
            : 'Escucha: ${r.word}. ¿Con qué sonido empieza? Toca la letra.';
      },
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
    required this.askFinal,
    required this.sound,
    required this.options,
  });

  final String emoji;
  final String word;
  final bool askFinal;
  final String sound;
  final List<String> options;
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
  int? _wrong;
  bool _solved = false;

  // Letras barajadas en cada partida.
  late final List<String> _options;

  @override
  void initState() {
    super.initState();
    _options = [...widget.round.options]..shuffle();
  }

  void _onTap(int index) {
    if (_solved) return;
    if (_options[index] == widget.round.sound) {
      setState(() => _solved = true);
      widget.controller.roundCorrect();
    } else {
      setState(() => _wrong = index);
      widget.controller.roundWrong();
    }
  }

  @override
  Widget build(BuildContext context) {
    final round = widget.round;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BigCard(
              label: round.emoji,
              size: 120,
              color: 'purple',
              state: _solved ? BigCardState.success : BigCardState.normal,
            ),
            const SizedBox(width: 16),
            SpeakerButton(
              onTap: () => TtsService.instance.speak(round.word),
              size: 56,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (var i = 0; i < _options.length; i++)
              BigCard(
                label: _options[i],
                size: 104,
                fontSize: 84,
                color: 'pink',
                state: _solved
                    ? (_options[i] == round.sound
                        ? BigCardState.success
                        : BigCardState.dimmed)
                    : _wrong == i
                        ? BigCardState.error
                        : BigCardState.normal,
                onTap: () => _onTap(i),
              ),
          ],
        ),
      ],
    );
  }
}