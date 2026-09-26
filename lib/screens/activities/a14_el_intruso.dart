import 'package:flutter/material.dart';

import '../../models/activity.dart';
import '../../widgets/activity/activity_host.dart';
import '../../widgets/activity/big_card.dart';

/// A14 · ¿Dónde está el intruso? — categorización semántica.
class A14ElIntruso extends StatelessWidget {
  const A14ElIntruso({super.key, required this.spec});

  final ActivitySpec spec;

  static const List<_Round> _rounds = [
    _Round(items: ['🐶', '🐱', '🚗', '🐰'], intruder: '🚗', speech: 'Toca el que no es un animal.'),
    _Round(items: ['🍎', '🍌', '🐟', '🍐'], intruder: '🐟', speech: 'Toca el que no es una fruta.'),
    _Round(items: ['⚽', '🏀', '🥕', '🎾'], intruder: '🥕', speech: 'Toca el que no es una pelota para jugar.'),
    _Round(items: ['🚗', '🚌', '🌵', '🚲'], intruder: '🌵', speech: 'Toca el que no es un vehículo.'),
    _Round(items: ['🪑', '🛏️', '🚪', '👗'], intruder: '👗', speech: 'Toca el que no es un mueble.'),
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
  const _Round({required this.items, required this.intruder, required this.speech});

  final List<String> items;
  final String intruder;
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

  // Dibujos barajados en cada partida.
  late final List<String> _items;

  @override
  void initState() {
    super.initState();
    _items = [...widget.round.items]..shuffle();
  }

  void _onTap(int i) {
    if (_solved) return;
    if (_items[i] == widget.round.intruder) {
      setState(() => _solved = true);
      widget.controller.roundCorrect();
    } else {
      setState(() => _wrong = i);
      widget.controller.roundWrong();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        spacing: 18,
        runSpacing: 18,
        alignment: WrapAlignment.center,
        children: [
          for (var i = 0; i < _items.length; i++)
            BigCard(
              label: _items[i],
              size: 124,
              color: 'yellow',
              state: _solved
                  ? (_items[i] == widget.round.intruder
                      ? BigCardState.success
                      : BigCardState.dimmed)
                  : _wrong == i
                      ? BigCardState.error
                      : BigCardState.normal,
              onTap: () => _onTap(i),
            ),
        ],
      ),
    );
  }
}