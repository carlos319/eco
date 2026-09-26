import 'package:flutter/material.dart';

import '../../models/activity.dart';
import '../../services/tts_service.dart';
import '../../widgets/activity/activity_host.dart';
import '../../widgets/activity/big_card.dart';
import '../../widgets/common.dart';

/// A04 · ¡Aplasta el sonido! — igualdad del sonido inicial.
///
/// Lía dice una palabra modelo; el niño aplasta todos los dibujos
/// que empiezan con el mismo sonido. 5 rondas.
class A04AplastaElSonido extends StatelessWidget {
  const A04AplastaElSonido({super.key, required this.spec});

  final ActivitySpec spec;

  static const List<_Round> _rounds = [
    _Round(
      example: 'mono',
      items: [
        _Item('🎒', 'mochila', true),
        _Item('🛵', 'moto', true),
        _Item('🦆', 'pato', false),
        _Item('🐢', 'tortuga', false),
      ],
    ),
    _Round(
      example: 'sol',
      items: [
        _Item('🐍', 'serpiente', true),
        _Item('🪑', 'silla', true),
        _Item('🌙', 'luna', false),
        _Item('🐈', 'gato', false),
      ],
    ),
    _Round(
      example: 'pato',
      items: [
        _Item('⚽', 'pelota', true),
        _Item('🐟', 'pez', true),
        _Item('🐒', 'mono', false),
        _Item('🌙', 'luna', false),
      ],
    ),
    _Round(
      example: 'luna',
      items: [
        _Item('🦁', 'león', true),
        _Item('✏️', 'lápiz', true),
        _Item('🍅', 'tomate', false),
        _Item('🥁', 'tambor', false),
      ],
    ),
    _Round(
      example: 'tomate',
      items: [
        _Item('🐢', 'tortuga', true),
        _Item('☕', 'taza', true),
        _Item('⚽', 'pelota', false),
        _Item('🎒', 'mochila', false),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ActivityHost(
      spec: spec,
      roundCount: _rounds.length,
      roundSpeech: (round) =>
          'Escucha: ${_rounds[round].example}. Aplasta los dibujos que '
          'empiezan igual que ${_rounds[round].example}.',
      roundBuilder: (context, round, controller) => _RoundView(
        key: ValueKey(round),
        round: _rounds[round],
        controller: controller,
      ),
    );
  }
}

class _Round {
  const _Round({required this.example, required this.items});

  final String example;
  final List<_Item> items;
}

class _Item {
  const _Item(this.emoji, this.word, this.startsSame);

  final String emoji;
  final String word;
  final bool startsSame;
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
  final Set<int> _found = {};
  int? _wrongTap;
  bool _solved = false;

  // Opciones barajadas en cada partida.
  late final List<_Item> _items;

  @override
  void initState() {
    super.initState();
    _items = [...widget.round.items]..shuffle();
  }

  int get _targetCount =>
      _items.where((i) => i.startsSame).length;

  void _onTap(int index) {
    if (_solved) return;
    final item = _items[index];
    if (item.startsSame) {
      if (_found.contains(index)) return;
      TtsService.instance.speak(item.word);
      setState(() {
        _found.add(index);
        _wrongTap = null;
      });
      if (_found.length == _targetCount) {
        _solved = true;
        widget.controller.roundCorrect();
      }
    } else {
      setState(() => _wrongTap = index);
      widget.controller.roundWrong();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        SpeakerButton(
          onTap: () => TtsService.instance.speak(widget.round.example),
          size: 62,
        ),
        const Spacer(),
        Expanded(
          child: Center(
            child: Wrap(
              spacing: 18,
              runSpacing: 18,
              alignment: WrapAlignment.center,
              children: [
                for (var i = 0; i < _items.length; i++) _cardFor(i),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _cardFor(int i) {
    final item = _items[i];
    final BigCardState state;
    if (_solved) {
      state = item.startsSame ? BigCardState.success : BigCardState.dimmed;
    } else if (_found.contains(i)) {
      state = BigCardState.success;
    } else if (_wrongTap == i) {
      state = BigCardState.error;
    } else {
      state = BigCardState.normal;
    }
    return BigCard(
      label: item.emoji,
      size: 124,
      color: 'orange',
      state: state,
      onTap: () => _onTap(i),
    );
  }
}