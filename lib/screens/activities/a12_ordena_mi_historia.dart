import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/activity.dart';
import '../../widgets/activity/activity_host.dart';
import '../../widgets/activity/big_card.dart';

/// A12 · Ordena mi historia — secuencias temporales.
class A12OrdenaMiHistoria extends StatelessWidget {
  const A12OrdenaMiHistoria({super.key, required this.spec});

  final ActivitySpec spec;

  static const List<_Round> _rounds = [
    _Round(order: ['🥚', '🐣', '🐔']),
    _Round(order: ['🌱', '🌿', '🌳']),
    _Round(order: ['☁️', '🌧️', '🌈']),
    _Round(order: ['🫋', '🐛', '🦋']),
    _Round(order: ['🪺', '🐦', '🐦‍⬛']),
  ];

  @override
  Widget build(BuildContext context) {
    return ActivityHost(
      spec: spec,
      roundCount: _rounds.length,
      roundSpeech: (round) =>
          'Toca los dibujos en orden: primero, después, al final.',
      roundBuilder: (context, round, controller) => _RoundView(
        key: ValueKey(round),
        round: _rounds[round],
        controller: controller,
      ),
    );
  }
}

class _Round {
  const _Round({required this.order});

  final List<String> order;
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
  int _placed = 0; // cuántos van bien
  late List<String> _shuffled;

  @override
  void initState() {
    super.initState();
    _shuffled = [...widget.round.order]..shuffle();
  }

  void _onTap(String emoji) {
    if (_placed >= widget.round.order.length) return;
    if (emoji == widget.round.order[_placed]) {
      setState(() => _placed += 1);
      if (_placed == widget.round.order.length) {
        widget.controller.roundCorrect();
      }
    } else {
      widget.controller.roundWrong();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Rieles: Primero · Después · Al final.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(widget.round.order.length, (i) {
            final done = i < _placed;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ['Primero', 'Después', 'Al final'][i],
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.ink.withOpacity(.6),
                  ),
                ),
                const SizedBox(height: 6),
                BigCard(
                  label: done ? widget.round.order[i] : '❓',
                  size: 92,
                  fontSize: 56,
                  color: 'green',
                  state: done ? BigCardState.success : BigCardState.normal,
                ),
              ],
            );
          }),
        ),
        // Dibujos desordenados (se van apagando al usarse).
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final e in _shuffled)
              BigCard(
                label: e,
                size: 96,
                color: 'purple',
                state: _placed > widget.round.order.indexOf(e)
                    ? BigCardState.dimmed
                    : BigCardState.normal,
                onTap: () => _onTap(e),
              ),
          ],
        ),
      ],
    );
  }
}