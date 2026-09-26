
import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/activity.dart';
import '../../widgets/activity/activity_host.dart';

/// A08 · Traza con el dedo — grafomotricidad del trazo.
///
/// Se traza una línea punteada (de izquierda a derecha y con curvas)
/// siguiendo los puntos. Cada punto tocado enciende. Al llegar a la
/// flor se gana la estrella de la ronda.
class A08TrazaConElDedo extends StatelessWidget {
  const A08TrazaConElDedo({super.key, required this.spec});

  final ActivitySpec spec;

  /// Recorridos por ronda: listas de puntos (fracciones de pantalla).
  static const List<List<Offset>> _paths = [
    // Ronda 1: línea recta izquierda→derecha.
    [
      Offset(.08, .5), Offset(.18, .5), Offset(.28, .5), Offset(.38, .5),
      Offset(.48, .5), Offset(.58, .5), Offset(.68, .5), Offset(.78, .5),
      Offset(.88, .5),
    ],
    // Ronda 2: montaña (sube y baja).
    [
      Offset(.1, .7), Offset(.2, .45), Offset(.3, .2), Offset(.4, .45),
      Offset(.5, .7), Offset(.6, .45), Offset(.7, .2), Offset(.8, .45),
      Offset(.9, .7),
    ],
    // Ronda 3: valle (baja y sube).
    [
      Offset(.1, .25), Offset(.2, .5), Offset(.3, .75), Offset(.4, .5),
      Offset(.5, .25), Offset(.6, .5), Offset(.7, .75), Offset(.8, .5),
      Offset(.9, .25),
    ],
    // Ronda 4: escalera hacia arriba.
    [
      Offset(.08, .8), Offset(.18, .8), Offset(.18, .6), Offset(.28, .6),
      Offset(.28, .4), Offset(.38, .4), Offset(.38, .2), Offset(.48, .2),
      Offset(.58, .2),
    ],
    // Ronda 5: onda grande.
    [
      Offset(.08, .6), Offset(.2, .3), Offset(.32, .6), Offset(.44, .3),
      Offset(.56, .6), Offset(.68, .3), Offset(.8, .6), Offset(.9, .4),
      Offset(.95, .25),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return ActivityHost(
      spec: spec,
      roundCount: _paths.length,
      roundSpeech: (round) =>
          'Traza con tu dedito sobre los puntitos, despacito, hasta llegar '
          'a la flor.',
      roundBuilder: (context, round, controller) => TraceBoard(
        key: ValueKey(round),
        points: _paths[round],
        onDone: () => controller.roundCorrect(
            phrase: '¡Muy bien! Lo trazaste completo.'),
      ),
    );
  }
}

/// Tablero de trazo: puntos que se encienden al tocarlos en orden.
class TraceBoard extends StatefulWidget {
  const TraceBoard({
    super.key,
    required this.points,
    required this.onDone,
  });

  /// Puntos del recorrido (fracciones del área de juego).
  final List<Offset> points;
  final VoidCallback onDone;

  @override
  State<TraceBoard> createState() => _TraceBoardState();
}

class _TraceBoardState extends State<TraceBoard> {
  int _lit = 0; // puntos encendidos

  void _onPanUpdate(DragUpdateDetails details, BoxConstraints c) {
    if (_lit >= widget.points.length) return;
    final next = widget.points[_lit];
    final nextAbs = Offset(
      next.dx * c.maxWidth,
      next.dy * c.maxHeight,
    );
    final d = (details.localPosition - nextAbs).distance;
    // Dedo grande + niños: radio generoso de captura.
    if (d < 46) {
      setState(() => _lit += 1);
      if (_lit == widget.points.length) {
        widget.onDone();
      }
    }
  }

  void _onPanStart(DragStartDetails details, BoxConstraints c) =>
      _onPanUpdate(
        DragUpdateDetails(delta: Offset.zero, globalPosition: details.globalPosition, localPosition: details.localPosition),
        c,
      );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final c = constraints;
        return GestureDetector(
          onPanStart: (d) => _onPanStart(d, c),
          onPanUpdate: (d) => _onPanUpdate(d, c),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppPalette.sky, width: 3),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: CustomPaint(
                painter: _TracePainter(
                  points: widget.points,
                  lit: _lit,
                  size: Size(c.maxWidth, c.maxHeight),
                ),
                size: Size.infinite,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Pinta la guía punteada, los puntos encendidos y el trazo del niño.
class _TracePainter extends CustomPainter {
  _TracePainter({
    required this.points,
    required this.lit,
    required this.size,
  });

  final List<Offset> points;
  final int lit;
  final Size size;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final pts = [
      for (final p in points) Offset(p.dx * size.width, p.dy * size.height),
    ];

    // 1. Guía punteada completa (suave).
    final guide = Paint()
      ..color = AppPalette.sky.withOpacity(.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    _dashedLine(canvas, pts, guide);

    // 2. Trazo encendido (lo que el niño ya recorrió).
    if (lit > 1) {
      final path = Path()..moveTo(pts[0].dx, pts[0].dy);
      for (var i = 1; i < lit; i++) {
        path.lineTo(pts[i].dx, pts[i].dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = AppPalette.orange
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // 3. Puntos: encendidos (naranjas) y por tocar (grises).
    for (var i = 0; i < pts.length; i++) {
      final done = i < lit;
      final paint = Paint()
        ..color = done ? AppPalette.orange : Colors.grey.shade400;
      canvas.drawCircle(pts[i], done ? 11 : 9, paint);
    }

    // 4. Origen (la oruga) y meta (la flor).
    _drawEmoji(canvas, '🐛', pts.first, 34);
    _drawEmoji(canvas, '🌸', pts.last, 34);
  }

  void _dashedLine(Canvas canvas, List<Offset> pts, Paint paint) {
    for (var i = 0; i < pts.length - 1; i++) {
      final a = pts[i];
      final b = pts[i + 1];
      final dashCount = (a - b).distance ~/ 14;
      for (var d = 1; d < dashCount; d++) {
        final t = d / dashCount;
        final p = Offset(a.dx + (b.dx - a.dx) * t, a.dy + (b.dy - a.dy) * t);
        canvas.drawCircle(p, 2, Paint()..color = paint.color);
      }
    }
  }

  void _drawEmoji(Canvas canvas, String emoji, Offset at, double size) {
    final tp = TextPainter(
      text: TextSpan(text: emoji, style: TextStyle(fontSize: size)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_TracePainter old) => old.lit != lit;
}