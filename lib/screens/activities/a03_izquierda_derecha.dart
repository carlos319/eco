
import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/activity.dart';
import '../../services/audio_service.dart';
import '../../widgets/activity/activity_host.dart';
import '../../widgets/activity/big_card.dart';

/// A03 · De izquierda a derecha — direccionalidad de la lectura.
///
/// La oruga tiene hambre: cada hoja aparece en un punto distinto de la
/// IZQUIERDA y se arrastra hasta su boca a la DERECHA (el sentido en
/// que luego se leerá). Cada hoja comida suma una estrella.
class A03IzquierdaDerecha extends StatelessWidget {
  const A03IzquierdaDerecha({super.key, required this.spec});

  final ActivitySpec spec;

  @override
  Widget build(BuildContext context) {
    return ActivityHost(
      spec: spec,
      roundCount: 1,
      roundSpeech: (_) =>
          'Arrastra cada hoja hasta la boca de la oruga. ¡Siempre hacia la derecha!',
      roundBuilder: (context, round, controller) =>
          _OrugaGame(controller: controller),
    );
  }
}

class _OrugaGame extends StatefulWidget {
  const _OrugaGame({required this.controller});

  final ActivityController controller;

  @override
  State<_OrugaGame> createState() => _OrugaGameState();
}

class _OrugaGameState extends State<_OrugaGame> with SingleTickerProviderStateMixin {
  static const int _totalLeaves = 5;


  int _eaten = 0;

  /// Alineación vertical de la hoja actual (varía en cada viaje).
  Alignment _leafAlignment = const Alignment(-.85, -.55);

  @override
  void initState() {
    super.initState();
    _newLeafPosition();
  }

  /// Cada hoja nace en una posición izquierda distinta (columna
  /// izquierda + alturas variadas): el trayecto nunca se memoriza.
  void _newLeafPosition() {
    const x = -0.78;
    const ys = [-0.62, -0.18, 0.28, 0.66, 0.05];
    _leafAlignment = Alignment(x, ys[_eaten % ys.length]);
  }

  Future<void> _feed() async {
    if (_eaten >= _totalLeaves) return;
    await AudioService.instance.pop();
    setState(() => _eaten += 1);
    if (_eaten < _totalLeaves) {
      _newLeafPosition();
      await widget.controller.bonusStar(phrase: '¡Ñam, ñam!');
    } else {
      // La quinta estrella dispara sola la celebración final del host.
      await widget.controller.bonusStar(phrase: '¡La oruga está feliz!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progreso: las hojitas que faltan.
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_totalLeaves, (i) {
              final eaten = i < _eaten;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Opacity(
                  opacity: eaten ? .25 : 1,
                  child: const Text('🍃', style: TextStyle(fontSize: 26)),
                ),
              );
            }),
          ),
        ),
        // Tablero: hoja en posición variable → flecha → oruga a la derecha.
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Recordatorio del sentido de la lectura (decorativo).
              Positioned(
                bottom: 8,
                right: 16,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'izquierda',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppPalette.ink.withOpacity(.4),
                        fontWeight: FontWeight.w600,
                    ),
                    ),
                    Icon(Icons.arrow_forward_rounded,
                        size: 20, color: AppPalette.sky),
                    Text(
                      'derecha',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppPalette.ink.withOpacity(.4),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // El juego.
              if (_eaten < _totalLeaves)
                Align(
                  alignment: _leafAlignment,
                  child: Draggable<String>(
                    data: 'leaf',
                    feedback: const Opacity(
                      opacity: .85,
                      child: BigCard(label: '🍃', size: 110, color: 'green'),
                    ),
                    childWhenDragging: const SizedBox(
                        width: 110, height: 110),
                    child: const BigCard(
                        label: '🍃', size: 110, color: 'green'),
                  ),
                ),
              // La oruga espera a la derecha, siempre en la misma altura.
              Align(
                alignment: const Alignment(.82, .1),
                child: DragTarget<String>(
                  onWillAccept: (data) => _eaten < _totalLeaves,
                  onAccept: (_) => _feed(),
                  builder: (context, candidates, _) {
                    return AnimatedScale(
                      duration: const Duration(milliseconds: 150),
                      scale: candidates.isNotEmpty ? 1.12 : 1,
                      child: const BigCard(
                        label: '🐛',
                        size: 130,
                        color: 'yellow',
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
}