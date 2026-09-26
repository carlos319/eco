import 'dart:math';

import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import 'buttons.dart';

/// Overlay de resultado estilo ppsx: "¡MUY BIEN!" o "No es esa".
class FeedbackOverlay extends StatelessWidget {
  const FeedbackOverlay({
    super.key,
    required this.correct,
    required this.message,
    required this.onContinue,
  });

  final bool correct;
  final String message;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final color = correct ? AppPalette.green : AppPalette.red;
    return Container(
      color: Colors.black.withOpacity(.35),
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: color, width: 3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              correct ? '🎉' : '🤔',
              style: const TextStyle(fontSize: 46),
            ),
            const SizedBox(height: 6),
            Text(
              correct ? '¡MUY BIEN!' : 'No es esa',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: color,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 18,
                color: AppPalette.ink,
              ),
            ),
            const SizedBox(height: 16),
            BigButton(
              label: 'Seguir',
              color: color,
              icon: Icons.arrow_forward_rounded,
              onPressed: onContinue,
              fontSize: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// Confeti simple sin dependencias externas.
class Celebration extends StatefulWidget {
  const Celebration({
    super.key,
    required this.child,
    this.pieces = 80,
    this.active = true,
  });

  final Widget child;
  final int pieces;
  final bool active;

  @override
  State<Celebration> createState() => _CelebrationState();
}

class _CelebrationState extends State<Celebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Piece> _pieces;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _pieces = List.generate(widget.pieces, _randomPiece);
  }

  _Piece _randomPiece(int i) {
    final colors = [
      AppPalette.sky,
      AppPalette.orange,
      AppPalette.green,
      AppPalette.pink,
      AppPalette.yellow,
      AppPalette.purple,
    ];
    return _Piece(
      x: _random.nextDouble(),
      delay: _random.nextDouble(),
      speed: .55 + _random.nextDouble() * .45,
      size: 8 + _random.nextDouble() * 8,
      color: colors[_random.nextInt(colors.length)],
      round: _random.nextBool(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.active)
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                painter: _ConfettiPainter(
                  pieces: _pieces,
                  progress: _controller.value,
                ),
                size: Size.infinite,
              ),
            ),
          ),
      ],
    );
  }
}

class _Piece {
  _Piece({
    required this.x,
    required this.delay,
    required this.speed,
    required this.size,
    required this.color,
    required this.round,
  });

  final double x;
  final double delay;
  final double speed;
  final double size;
  final Color color;
  final bool round;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.pieces, required this.progress});

  final List<_Piece> pieces;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in pieces) {
      var t = (progress * p.speed + p.delay) % 1;
      final dx = p.x * size.width +
          sin((t + p.delay) * 2 * pi) * 22; // balanceo lateral
      final dy = t * size.height;
      final paint = Paint()..color = p.color;
      final rect = Rect.fromCenter(
        center: Offset(dx, dy),
        width: p.size,
        height: p.size * 1.4,
      );
      if (p.round) {
        canvas.drawCircle(rect.center, p.size / 2, paint);
      } else {
        canvas.save();
        canvas.translate(rect.center.dx, rect.center.dy);
        canvas.rotate(t * 3 * pi);
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 1.4,
          ),
          paint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
