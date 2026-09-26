import 'package:flutter/material.dart';

import '../../models/activity.dart';
import '../../widgets/activity/activity_host.dart';
import '../../widgets/activity/big_card.dart';

/// A11 · ¿Qué sigue? — anticipar el final de una secuencia.
class A11QueSigue extends StatelessWidget {
  const A11QueSigue({super.key, required this.spec});

  final ActivitySpec spec;

  static const List<_Round> _rounds = [
    _Round(
      story: ['🌱', '🌿', '🍃'],
      answer: '🌸',
      options: ['🌸', '🚗', '⭐'],
      speech: 'Mira la historia: semilla, brote, hojitas. ¿Qué sigue?',
    ),
    _Round(
      story: ['🥚', '🐣', '🐤'],
      answer: '🐔',
      options: ['🐔', '🐟', '🎈'],
      speech: 'El huevo se abre, el pollito nace y crece. ¿Qué sigue?',
    ),
    _Round(
      story: ['☀️', '🌤️', '🌇'],
      answer: '🌙',
      options: ['🌙', '🍕', '🚀'],
      speech: 'Es de día, luego la tarde. ¿Qué viene al final?',
    ),
    _Round(
      story: ['☁️', '🌧️', '☔'],
      answer: '🌈',
      options: ['🌈', '🍐', '🎺'],
      speech: 'Nubes, lluvia, paraguas. ¿Qué aparece después de la lluvia?',
    ),
    _Round(
      story: ['🐛', '💤', '🛏️'],
      answer: '🦋',
      options: ['🦋', '🥕', '⚽'],
      speech: 'La oruga come, duerme... ¡y se convierte en...!',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ActivityHost(
      spec: spec,
      roundCount: _rounds.length,
      roundSpeech: (round) => _rounds[round].speech,
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
    required this.story,
    required this.answer,
    required this.options,
    required this.speech,
  });

  final List<String> story;
  final String answer;
  final List<String> options;
  final String speech;
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

  // Opciones barajadas en cada partida.
  late final List<String> _options;

  @override
  void initState() {
    super.initState();
    _options = [...widget.round.options]..shuffle();
  }

  void _onTap(int i) {
    if (_solved) return;
    if (_options[i] == widget.round.answer) {
      setState(() => _solved = true);
      widget.controller.roundCorrect();
    } else {
      setState(() => _wrong = i);
      widget.controller.roundWrong();
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.round;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final e in r.story)
              BigCard(label: e, size: 86, color: 'orange'),
            const Icon(Icons.arrow_forward_rounded,
                size: 34, color: Colors.grey),
            BigCard(
              label: _solved ? r.answer : '?',
              size: 86,
              fontSize: 56,
              color: 'green',
              state: _solved ? BigCardState.success : BigCardState.normal,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (var i = 0; i < _options.length; i++)
              BigCard(
                label: _options[i],
                size: 100,
                color: 'purple',
                state: _solved
                    ? (_options[i] == r.answer
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