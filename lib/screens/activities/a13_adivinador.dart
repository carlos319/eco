import 'package:flutter/material.dart';

import '../../models/activity.dart';
import '../../services/tts_service.dart';
import '../../widgets/activity/activity_host.dart';
import '../../widgets/activity/big_card.dart';
import '../../widgets/common.dart';

/// A13 · Adivina adivinador — comprensión oral.
class A13Adivinador extends StatelessWidget {
  const A13Adivinador({super.key, required this.spec});

  final ActivitySpec spec;

  static const List<_Round> _rounds = [
    _Round(
      riddle: 'Redonda y amarilla, brilla en el cielo de noche. ¿Qué es?',
      answer: '🌙',
      options: ['🌙', '🍅', '🚗'],
    ),
    _Round(
      riddle: 'Verde por fuera, roja por dentro, con pepitas negras. ¿Qué es?',
      answer: '🍉',
      options: ['🍉', '🐸', '🥁'],
    ),
    _Round(
      riddle: 'Es amarillo y largo, y el mono lo adora comer. ¿Qué es?',
      answer: '🍌',
      options: ['🍌', '🌙', '🧢'],
    ),
    _Round(
      riddle: 'Tiene orejas largas, saltando va de aquí para allá. ¿Quién es?',
      answer: '🐰',
      options: ['🐰', '🐘', '🐍'],
    ),
    _Round(
      riddle: 'Dice guau guau, y es el mejor amigo de las personas. ¿Quién es?',
      answer: '🐶',
      options: ['🐶', '🐱', '🐟'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ActivityHost(
      spec: spec,
      roundCount: _rounds.length,
      roundSpeech: (round) => _rounds[round].riddle,
      roundBuilder: (context, round, controller) => _RoundView(
        key: ValueKey(round),
        round: _rounds[round],
        controller: controller,
      ),
    );
  }
}

class _Round {
  const _Round({required this.riddle, required this.answer, required this.options});

  final String riddle;
  final String answer;
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
  // Respuestas barajadas en cada partida.
  late final List<String> _options;

  @override
  void initState() {
    super.initState();
    _options = [...widget.round.options]..shuffle();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SpeakerButton(
          onTap: () =>
              TtsService.instance.speakSentence(widget.round.riddle),
          size: 66,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final emoji in _options)
              _OptionTap(
                emoji: emoji,
                isAnswer: emoji == widget.round.answer,
                controller: widget.controller,
              ),
          ],
        ),
      ],
    );
  }
}

class _OptionTap extends StatefulWidget {
  const _OptionTap({
    required this.emoji,
    required this.isAnswer,
    required this.controller,
  });

  final String emoji;
  final bool isAnswer;
  final ActivityController controller;

  @override
  State<_OptionTap> createState() => _OptionTapState();
}

class _OptionTapState extends State<_OptionTap> {
  bool _solved = false;
  bool _wrong = false;

  void _onTap() {
    if (_solved) return;
    if (widget.isAnswer) {
      setState(() => _solved = true);
      widget.controller.roundCorrect();
    } else {
      setState(() => _wrong = true);
      widget.controller.roundWrong();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BigCard(
      label: widget.emoji,
      size: 104,
      color: 'pink',
      state: _solved
          ? BigCardState.success
          : _wrong
              ? BigCardState.error
              : BigCardState.normal,
      onTap: _onTap,
    );
  }
}