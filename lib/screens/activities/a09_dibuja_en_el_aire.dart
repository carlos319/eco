import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/activity.dart';
import '../../services/tts_service.dart';
import '../../widgets/activity/activity_host.dart';
import '../../widgets/buttons.dart';

/// A09 · Dibuja en el aire — grafomotricidad corporal con espejo.
///
/// La cámara frontal muestra al niño mientras traza la figura guía
/// con el dedo sobre la pantalla. Al terminar, se compara el trazo
/// con el modelo (precisión + cobertura) y se le da una puntuación.
/// Sin cámara o sin permiso: se juega igual con fondo de color.
class A09DibujaEnElAire extends StatelessWidget {
  const A09DibujaEnElAire({super.key, required this.spec});

  final ActivitySpec spec;

  static const List<_Figure> _figures = [
    _Figure(
      emoji: '❤️',
      name: 'un corazón',
      speech: 'Dibuja un corazón grandote, siguiendo los puntitos '
          'blancos. ¡Empieza por arriba!',
      make: _heart,
    ),
    _Figure(
      emoji: '⭕',
      name: 'un círculo',
      speech: 'Dibuja un círculo bien redondo. ¡Una vuelta entera!',
      make: _circle,
    ),
    _Figure(
      emoji: '➡️',
      name: 'una línea',
      speech: 'Dibuja la línea de abajo hacia arriba, '
          'de izquierda a derecha. ¡Como cuando lees!',
      make: _diagonal,
    ),
    _Figure(
      emoji: '🔺',
      name: 'un triángulo',
      speech: 'Dibuja un triángulo: arriba, abajo a la derecha, '
          'abajo a la izquierda, ¡y cierra!',
      make: _triangle,
    ),
    _Figure(
      emoji: '♾️',
      name: 'un ocho acostado',
      speech: '¡La última! Dibuja un ocho acostado, sin levantar '
          'el dedo. ¡Tú puedes!',
      make: _infinity,
    ),
  ];

  // -------------------------------------------------- generadores (0..1)

  /// Corazón paramétrico clásico, normalizado al área de juego.
  static List<Offset> _heart() {
    final raw = <Offset>[];
    for (var t = 0.0; t <= 2 * math.pi + .01; t += 2 * math.pi / 120) {
      final x = 16 * math.pow(math.sin(t), 3).toDouble();
      final y = 13 * math.cos(t) -
          5 * math.cos(2 * t) -
          2 * math.cos(3 * t) -
          math.cos(4 * t);
      raw.add(Offset(x, -y)); // invertir Y (pantalla crece hacia abajo)
    }
    return _normalize(raw, marginX: .1, marginY: .12);
  }

  static List<Offset> _circle() => _normalize([
        for (var t = 0.0; t <= 2 * math.pi + .01; t += 2 * math.pi / 90)
          Offset(math.cos(t), math.sin(t)),
      ]);

  static List<Offset> _diagonal() => _normalize([
        for (var i = 0; i <= 60; i++)
          Offset(i / 60, -i / 60), // abajo-izquierda → arriba-derecha
      ]);

  static List<Offset> _triangle() => _normalize([
        for (var i = 0; i <= 40; i++)
          Offset(i / 40, i / 40), // vértice → derecha
        for (var i = 0; i <= 40; i++)
          Offset(1 - i / 40, i / 40), // derecha → izquierda
        for (var i = 0; i <= 40; i++)
          Offset(i / 40, 1 - i / 40), // izquierda → vértice
      ]);

  /// Ocho acostado (Lissajous 1:2).
  static List<Offset> _infinity() => _normalize([
        for (var t = 0.0; t <= 2 * math.pi + .01; t += 2 * math.pi / 140)
          Offset(math.cos(t), math.sin(2 * t)),
      ]);

  /// Centra y escala una figura al cuadro [margin..1-margin].
  static List<Offset> _normalize(
    List<Offset> raw, {
    double marginX = .12,
    double marginY = .15,
  }) {
    var minX = raw.first.dx, maxX = raw.first.dx;
    var minY = raw.first.dy, maxY = raw.first.dy;
    for (final p in raw) {
      minX = math.min(minX, p.dx);
      maxX = math.max(maxX, p.dx);
      minY = math.min(minY, p.dy);
      maxY = math.max(maxY, p.dy);
    }
    final sx = (1 - 2 * marginX) / (maxX - minX);
    final sy = (1 - 2 * marginY) / (maxY - minY);
    final s = math.min(sx, sy); // mantiene proporción
    final cx = (minX + maxX) / 2, cy = (minY + maxY) / 2;
    return [
      for (final p in raw)
        Offset(.5 + (p.dx - cx) * s, .5 + (p.dy - cy) * s),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ActivityHost(
      spec: spec,
      roundCount: _figures.length,
      roundSpeech: (round) => _figures[round].speech,
      roundBuilder: (context, round, controller) => _TraceRound(
        key: ValueKey(round),
        figure: _figures[round],
        controller: controller,
      ),
    );
  }
}

class _Figure {
  const _Figure({
    required this.emoji,
    required this.name,
    required this.speech,
    required this.make,
  });

  final String emoji;
  final String name;
  final String speech;
  final List<Offset> Function() make;
}

/// Pantalla de una ronda: cámara de fondo + figura guía + trazo.
class _TraceRound extends StatefulWidget {
  const _TraceRound({
    super.key,
    required this.figure,
    required this.controller,
  });

  final _Figure figure;
  final ActivityController controller;

  @override
  State<_TraceRound> createState() => _TraceRoundState();
}

class _TraceRoundState extends State<_TraceRound> {
  CameraController? _camera;
  bool _cameraTried = false;

  late final List<Offset> _model; // puntos del modelo (0..1)
  final List<Offset> _stroke = []; // puntos del trazo (0..1)

  int? _lastScore;
  bool _solved = false;

  /// Tolerancia: fracción del área de juego (dedos de niño = generoso).
  static const _tolerance = .11;

  @override
  void initState() {
    super.initState();
    _model = widget.figure.make();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (!mounted) return;
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        front,
        ResolutionPreset.low,
        enableAudio: false,
      );
      await controller.initialize();
      if (mounted) setState(() => _camera = controller);
    } catch (_) {
      // Sin cámara o sin permiso: se juega igual con fondo de color.
    } finally {
      _cameraTried = true;
    }
  }

  @override
  void dispose() {
    _camera?.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------- el trazo

  void _addPoint(Offset local, Size size) {
    if (size == Size.zero) return;
    setState(() {
      _stroke.add(Offset(local.dx / size.width, local.dy / size.height));
    });
  }

  // ---------------------------------------------------------- evaluación

  /// Puntuación 0–100: mitad precisión (trazo cerca del modelo),
  /// mitad cobertura (cuánto del modelo recorrió el trazo).
  int _computeScore() {
    if (_stroke.isEmpty) return 0;
    var near = 0;
    for (final s in _stroke) {
      var minD = double.infinity;
      for (final m in _model) {
        final d = (m - s).distance;
        if (d < minD) minD = d;
      }
      if (minD <= _tolerance) near++;
    }
    final precision = near / _stroke.length;

    var covered = 0;
    for (final m in _model) {
      for (final s in _stroke) {
        if ((m - s).distance <= _tolerance * 1.4) {
          covered++;
          break;
        }
      }
    }
    final coverage = covered / _model.length;

    return ((precision * .5 + coverage * .5) * 100).round();
  }

  Future<void> _evaluate() async {
    if (_solved) return;
    if (_stroke.length < 8) {
      await TtsService.instance.speakSentence(
          'Primero dibuja la figura con tu dedo sobre los puntitos.');
      return;
    }
    final score = _computeScore();
    setState(() => _lastScore = score);
    if (score >= 55) {
      setState(() => _solved = true);
      final phrase = score >= 85
          ? '¡Perfecto!'
          : score >= 70
              ? '¡Muy bien!'
              : '¡Bien!';
      widget.controller
          .roundCorrect(phrase: '$phrase Sacaste $score de 100.');
    } else {
      widget.controller.roundWrong(
          phrase: 'Casi casi... te faltó un poquito. ¡Inténtalo otra vez!');
      setState(_stroke.clear);
    }
  }

  // -------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Fondo: cámara o color.
                if (_camera != null)
                  FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _camera!.value.previewSize!.height,
                      height: _camera!.value.previewSize!.width,
                      child: CameraPreview(_camera!),
                    ),
                  )
                else if (!_cameraTried)
                  Container(color: AppPalette.sky.withOpacity(.2))
                else
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppPalette.sky.withOpacity(.25),
                          AppPalette.purple.withOpacity(.2),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Text('🪞', style: TextStyle(fontSize: 64)),
                    ),
                  ),
                // Zona de trazo.
                LayoutBuilder(
                  builder: (context, constraints) {
                    final size = Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                    return GestureDetector(
                      onPanStart: (d) =>
                          _addPoint(d.localPosition, size),
                      onPanUpdate: (d) =>
                          _addPoint(d.localPosition, size),
                      child: CustomPaint(
                        painter: _ShapePainter(
                          model: _model,
                          stroke: _stroke,
                          solved: _solved,
                        ),
                        size: Size.infinite,
                      ),
                    );
                  },
                ),
                // Puntuación flotante.
                if (_lastScore != null)
                  Positioned(
                    top: 10,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _solved
                              ? AppPalette.green
                              : AppPalette.orange,
                          width: 2.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.figure.emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$_lastScore/100',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: _solved
                                  ? AppPalette.green
                                  : AppPalette.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            BigButton(
              label: 'Borrar',
              color: AppPalette.sky,
              icon: Icons.refresh_rounded,
              onPressed: _solved
                  ? null
                  : () => setState(_stroke.clear),
            ),
            BigButton(
              label: '¡Listo!',
              color: AppPalette.green,
              icon: Icons.check_rounded,
              onPressed: _solved ? null : _evaluate,
            ),
          ],
        ),
      ],
    );
  }
}

/// Pinta la figura guía (puntitos blancos) y el trazo del niño.
class _ShapePainter extends CustomPainter {
  _ShapePainter({
    required this.model,
    required this.stroke,
    required this.solved,
  });

  final List<Offset> model;
  final List<Offset> stroke;
  final bool solved;

  @override
  void paint(Canvas canvas, Size size) {
    final m = [
      for (final p in model) Offset(p.dx * size.width, p.dy * size.height),
    ];
    final s = [
      for (final p in stroke) Offset(p.dx * size.width, p.dy * size.height),
    ];

    // 1. Guía: puntitos blancos con halo (visibles sobre cámara y color).
    for (final p in m) {
      canvas.drawCircle(
        p, 11,
        Paint()..color = Colors.white.withOpacity(.35),
      );
      canvas.drawCircle(p, 6.5, Paint()..color = Colors.white);
    }

    // 2. Trazo del niño.
    if (s.length > 1) {
      final path = Path()..moveTo(s.first.dx, s.first.dy);
      for (var i = 1; i < s.length; i++) {
        path.lineTo(s[i].dx, s[i].dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = solved ? AppPalette.green : AppPalette.orange
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  @override
  bool shouldRepaint(_ShapePainter old) => true;
}