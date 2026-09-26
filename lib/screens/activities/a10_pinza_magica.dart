import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/activity.dart';
import '../../services/audio_service.dart';
import '../../services/tts_service.dart';
import '../../widgets/activity/activity_host.dart';
import '../../widgets/activity/big_card.dart';

/// A10 · Pinza mágica — motricidad fina + secuencia de colores.
///
/// Cada ronda dicta un orden de colores por voz. Las bolitas deben
/// guardarse en el frasco UNA POR UNA siguiendo ese orden: coger la
/// equivocada es un error amable (vuelve a su sitio y Lía recuerda
/// cuál va). Completar el orden da la estrella de la ronda.
class A10PinzaMagica extends StatelessWidget {
  const A10PinzaMagica({super.key, required this.spec});

  final ActivitySpec spec;

  static const _red = _Ball('🔴', 'roja');
  static const _blue = _Ball('🔵', 'azul');
  static const _green = _Ball('🟢', 'verde');
  static const _yellow = _Ball('🟡', 'amarilla');
  static const _purple = _Ball('🟣', 'morada');

  /// Órdenes por ronda: se agranda la dificultad (3 → 5 bolitas)
  /// y cada ronda tiene un orden distinto.
  static const List<List<_Ball>> _orders = [
    [_red, _blue, _green],
    [_yellow, _red, _purple, _blue],
    [_red, _blue, _green, _yellow, _purple],
    [_green, _purple, _yellow, _blue, _red],
    [_purple, _yellow, _blue, _green, _red],
  ];

  /// La voz que dicta el orden de la ronda.
  static String _orderSpeech(List<_Ball> order) {
    final parts = <String>[];
    for (var i = 0; i < order.length; i++) {
      if (i == 0) {
        parts.add('primero la ${order[i].name}');
      } else if (i == order.length - 1) {
        parts.add('y al final la ${order[i].name}');
      } else {
        parts.add('después la ${order[i].name}');
      }
    }
    return 'Guarda las bolitas en el frasco en orden: ${parts.join(', ')}.';
  }

  @override
  Widget build(BuildContext context) {
    return ActivityHost(
      spec: spec,
      roundCount: _orders.length,
      roundSpeech: (round) => _orderSpeech(_orders[round]),
      roundBuilder: (context, round, controller) => _RoundView(
        key: ValueKey(round),
        order: _orders[round],
        controller: controller,
      ),
    );
  }
}

class _Ball {
  const _Ball(this.emoji, this.name);

  final String emoji;

  /// Nombre hablado del color.
  final String name;
}

class _RoundView extends StatefulWidget {
  const _RoundView({
    super.key,
    required this.order,
    required this.controller,
  });

  final List<_Ball> order;
  final ActivityController controller;

  @override
  State<_RoundView> createState() => _RoundViewState();
}

class _RoundViewState extends State<_RoundView> {
  int _placed = 0; // bolitas guardadas en orden
  bool _done = false;

  _Ball get _next => widget.order[_placed];

  /// Posiciones fijas de las bolitas dispersas (máx. 5 por ronda).
  static const _spots = [
    Alignment(-.7, -.5),
    Alignment(.65, -.55),
    Alignment(-.75, -.05),
    Alignment(.7, 0),
    Alignment(-.1, -.75),
  ];

  Future<void> _onDrop(String name) async {
    if (_done) return;
    if (name == _next.name) {
      // ✔ Bolita correcta del orden.
      await AudioService.instance.pop();
      setState(() => _placed += 1);
      if (_placed >= widget.order.length) {
        // Orden completo: estrella de la ronda.
        setState(() => _done = true);
        await widget.controller.roundCorrect();
      } else {
        await TtsService.instance.speak('Ahora la ${_next.name}.');
      }
    } else {
      // ✘ Bolita fuera de orden: error amable + recordatorio.
      await widget.controller.roundWrong(
        phrase: 'Todavía no. Ahora guarda la ${_next.name}.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Guía del orden: la siguiente resaltada, las hechas apagadas.
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.order.length; i++) _guideBall(i),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              // Bolitas dispersas: solo las que faltan guardar.
              for (var i = _placed; i < widget.order.length; i++)
                Align(
                  alignment: _spots[i],
                  child: Draggable<String>(
                    data: widget.order[i].name,
                    feedback: Opacity(
                      opacity: .85,
                      child: Text(
                        widget.order[i].emoji,
                        style: const TextStyle(fontSize: 56),
                      ),
                    ),
                    childWhenDragging: const SizedBox(),
                    child: Text(
                      widget.order[i].emoji,
                      style: const TextStyle(fontSize: 56),
                    ),
                  ),
                ),
              // El frasco: acepta cualquier soltada y juzga el orden.
              Align(
                alignment: const Alignment(0, .8),
                child: DragTarget<String>(
                  onWillAccept: (_) => !_done,
                  onAccept: _onDrop,
                  builder: (context, candidates, _) {
                    final hover = candidates.isNotEmpty;
                    return AnimatedScale(
                      duration: const Duration(milliseconds: 150),
                      scale: hover ? 1.12 : 1,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Las bolitas ya guardadas, dentro del frasco.
                          SizedBox(
                            height: 32,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (var i = 0; i < _placed; i++)
                                  Text(
                                    widget.order[i].emoji,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                              ],
                            ),
                          ),
                          BigCard(
                            label: '🫙',
                            size: 110,
                            color: _done ? 'green' : 'sky',
                            state: _done
                                ? BigCardState.success
                                : BigCardState.normal,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Bolita de la guía con su número de posición.
  Widget _guideBall(int i) {
    final isNext = !_done && i == _placed;
    final isDone = i < _placed;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isNext ? AppPalette.orange.withOpacity(.15) : null,
              border:
                  isNext ? Border.all(color: AppPalette.orange, width: 3) : null,
            ),
            child: Opacity(
              opacity: isDone ? .3 : 1,
              child: Text(
                widget.order[i].emoji,
                style: TextStyle(fontSize: isNext ? 30 : 24),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${i + 1}',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isDone
                  ? AppPalette.green
                  : isNext
                      ? AppPalette.orange
                      : AppPalette.ink.withOpacity(.4),
            ),
          ),
        ],
      ),
    );
  }
}