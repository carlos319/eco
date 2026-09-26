import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/activity.dart';
import '../../widgets/activity/activity_host.dart';
import '../../widgets/activity/big_card.dart';

/// A02 · ¿Qué le falta? — reconocer que un todo se compone de partes.
///
/// 5 rondas: se arrastra la pieza que falta hasta el hueco junto al
/// dibujo. Pieza correcta = acierto; incorrecta = error amable y vuelve.
class A02QueLeFalta extends StatelessWidget {
  const A02QueLeFalta({super.key, required this.spec});

  final ActivitySpec spec;

  static const List<_Round> _rounds = [
    _Round(
      subject: '🐛',
      missing: '🍃',
      decoys: ['🍕', '🎈'],
      speech: 'La oruga quiere comer. Arrastra su hoja hasta el hueco.',
    ),
    _Round(
      subject: '🐝',
      missing: '🌸',
      decoys: ['🍎', '⭐'],
      speech: 'La abeja busca una flor. Arrastra la flor.',
    ),
    _Round(
      subject: '🐟',
      missing: '💧',
      decoys: ['🔥', '🍪'],
      speech: 'El pez necesita agua. Arrastra el agua.',
    ),
    _Round(
      subject: '🐦',
      missing: '🌳',
      decoys: ['🚗', '🍌'],
      speech: 'El pajarito quiere su árbol. Arrastra el árbol.',
    ),
    _Round(
      subject: '🐘',
      missing: '🥜',
      decoys: ['🧊', '🍉'],
      speech: 'Al elefante le falta su maní. Arrastra el maní.',
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

/// Una ronda: sujeto, pieza que falta y distractores.
class _Round {
  const _Round({
    required this.subject,
    required this.missing,
    required this.decoys,
    required this.speech,
  });

  final String subject;
  final String missing;
  final List<String> decoys;
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
  bool _solved = false;

  void _onAccept(String data) {
    if (_solved) return;
    if (data == widget.round.missing) {
      setState(() => _solved = true);
      widget.controller.roundCorrect();
    } else {
      widget.controller.roundWrong();
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = [...widget.round.decoys, widget.round.missing]..shuffle();

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Tablero: dibujo + hueco.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BigCard(
              label: widget.round.subject,
              size: 130,
              color: 'sky',
              state: _solved ? BigCardState.success : BigCardState.normal,
            ),
            const SizedBox(width: 24),
            DragTarget<String>(
              onWillAccept: (data) => !_solved,
              onAccept: _onAccept,
              builder: (context, candidates, _) {
                if (_solved) {
                  return const BigCard(
                    label: '',
                    size: 130,
                    color: 'green',
                    state: BigCardState.success,
                  );
                }
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: candidates.isNotEmpty
                        ? AppPalette.green.withOpacity(.15)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: candidates.isNotEmpty
                          ? AppPalette.green
                          : AppPalette.sky,
                      width: 3,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      '?',
                      style: TextStyle(
                        fontSize: 58,
                        fontWeight: FontWeight.w800,
                        color: AppPalette.ink,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        // Opciones arrastrables.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final option in options)
              Draggable<String>(
                data: option,
                feedback: Opacity(
                  opacity: .85,
                  child: BigCard(
                    label: option,
                    size: 110,
                    color: 'orange',
                  ),
                ),
                childWhenDragging: BigCard(
                  label: option,
                  size: 110,
                  color: 'orange',
                  state: BigCardState.dimmed,
                ),
                child: BigCard(
                  label: option,
                  size: 110,
                  color: 'orange',
                  state: _solved
                      ? BigCardState.dimmed
                      : BigCardState.normal,
                ),
              ),
          ],
        ),
      ],
    );
  }
}