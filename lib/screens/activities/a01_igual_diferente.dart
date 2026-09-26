import 'package:flutter/material.dart';

import '../../models/activity.dart';
import '../../widgets/activity/activity_host.dart';
import '../../widgets/activity/big_card.dart';

/// A01 · Igual o diferente — discriminar el elemento distinto en una fila.
///
/// 5 rondas: 3 con dibujos y 2 con letras gemelas (m/m-n, b/d),
/// los conflictos clásicos de la lectoescritura.
class A01IgualDiferente extends StatelessWidget {
  const A01IgualDiferente({super.key, required this.spec});

  final ActivitySpec spec;

  static const List<_Round> _rounds = [
    _Round(
      items: ['🍎', '🍎', '🍌', '🍎'],
      odd: 2,
      speech: 'Toca la fruta diferente.',
    ),
    _Round(
      items: ['🐶', '🐱', '🐶', '🐶'],
      odd: 1,
      speech: 'Toca el animal diferente.',
    ),
    _Round(
      items: ['⭐', '⭐', '⭐', '❤️'],
      odd: 3,
      speech: '¡Casi iguales! Toca el que es diferente.',
    ),
    _Round(
      items: ['m', 'm', 'n', 'm'],
      odd: 2,
      speech: '¡Muy parecidas! Toca la letra diferente.',
    ),
    _Round(
      items: ['b', 'd', 'b', 'b'],
      odd: 1,
      speech: '¡Muy parecidas! Toca la letra diferente.',
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

/// Una ronda: 4 tarjetas, una es el intruso.
class _Round {
  const _Round({required this.items, required this.odd, required this.speech});

  final List<String> items;
  final int odd; // índice del intruso
  final String speech;
}

/// Fila de tarjetas táctiles con estado de acierto/error.
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
  int? _tapped;
  bool _solved = false;

  // Opciones barajadas: el intruso cambia de posición en cada partida.
  late final List<String> _items;
  late final int _odd;

  @override
  void initState() {
    super.initState();
    _items = [...widget.round.items]..shuffle();
    _odd = _items.indexOf(widget.round.items[widget.round.odd]);
  }

  void _onTap(int index) {
    if (_solved) return;
    if (index == _odd) {
      setState(() {
        _tapped = index;
        _solved = true;
      });
      widget.controller.roundCorrect();
    } else {
      setState(() => _tapped = index);
      widget.controller.roundWrong();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLetters = _items.first.length == 1;
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size =
              ((constraints.maxWidth - 3 * 12) / 4).clamp(90.0, 130.0);
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_items.length, (i) {
              final state = _solved
                  ? (i == _odd
                      ? BigCardState.success
                      : BigCardState.dimmed)
                  : _tapped == i
                      ? BigCardState.error
                      : BigCardState.normal;
              return BigCard(
                label: _items[i],
                size: size,
                fontSize: isLetters ? 84 : 64,
                color: 'sky',
                state: state,
                onTap: () => _onTap(i),
              );
            }),
          );
        },
      ),
    );
  }
}