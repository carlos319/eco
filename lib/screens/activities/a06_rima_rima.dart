import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/activity.dart';
import '../../widgets/activity/activity_host.dart';

/// A06 · Rima, rima — discriminación de rimas.
class A06RimaRima extends StatelessWidget {
  const A06RimaRima({super.key, required this.spec});

  final ActivitySpec spec;

  static const List<_Round> _rounds = [
    _Round(aEmoji: '🐈', aWord: 'gato', bEmoji: '🦆', bWord: 'pato', rhymes: true),
    _Round(aEmoji: '🌙', aWord: 'luna', bEmoji: '🐳', bWord: 'ballena', rhymes: false),
    _Round(aEmoji: '🐭', aWord: 'ratón', bEmoji: '🚚', bWord: 'camión', rhymes: true),
    _Round(aEmoji: '☀️', aWord: 'sol', bEmoji: '🐌', bWord: 'caracol', rhymes: true),
    _Round(aEmoji: '🌸', aWord: 'flor', bEmoji: '🐟', bWord: 'pez', rhymes: false),
  ];

  @override
  Widget build(BuildContext context) {
    return ActivityHost(
      spec: spec,
      roundCount: _rounds.length,
      roundSpeech: (round) {
        final r = _rounds[round];
        return 'Escucha: ${r.aWord}, ${r.bWord}. ¿Riman? Al imán si riman, '
            'a la canasta si no riman.';
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
    required this.aEmoji,
    required this.aWord,
    required this.bEmoji,
    required this.bWord,
    required this.rhymes,
  });

  final String aEmoji;
  final String aWord;
  final String bEmoji;
  final String bWord;
  final bool rhymes;
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

  void _drop(bool toMagnet) {
    if (_solved) return;
    if (toMagnet == widget.round.rhymes) {
      setState(() => _solved = true);
      widget.controller.roundCorrect();
    } else {
      widget.controller.roundWrong(phrase: 'Escucha otra vez. ¿Riman?');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pair = _buildPair();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _solved
            ? pair
            : Draggable<String>(
                data: 'pair',
                feedback: _buildPair(),
                childWhenDragging: Opacity(opacity: .3, child: _buildPair()),
                child: pair,
              ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _DropZone(
              emoji: '🧲',
              label: '¡Riman!',
              color: AppPalette.green,
              onAccept: () => _drop(true),
            ),
            _DropZone(
              emoji: '🗑️',
              label: 'No riman',
              color: AppPalette.orange,
              onAccept: () => _drop(false),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPair() {
    final r = widget.round;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _solved ? AppPalette.green : AppPalette.sky,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppPalette.sky.withOpacity(.3),
            offset: const Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _word(r.aEmoji, r.aWord),
          const SizedBox(width: 26),
          _word(r.bEmoji, r.bWord),
        ],
      ),
    );
  }

  Widget _word(String emoji, String word) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 52)),
        const SizedBox(height: 2),
        Text(
          word,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppPalette.ink,
          ),
        ),
      ],
    );
  }
}

class _DropZone extends StatelessWidget {
  const _DropZone({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onAccept,
  });

  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onWillAccept: (_) => true,
      onAccept: (_) => onAccept(),
      builder: (context, candidates, _) {
        final hover = candidates.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 150,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: hover ? color.withOpacity(.2) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: hover ? color : color.withOpacity(.5),
              width: 3,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 52)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}