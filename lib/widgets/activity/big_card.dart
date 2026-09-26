import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

/// Estado visual de una [BigCard].
enum BigCardState { normal, success, error, dimmed }

/// Tarjeta táctil grande (mínimo 120x120 dp) para pictogramas y letras.
///
/// - normal: fondo blanco con sombra 3D del color dado.
/// - success: aplasta con rebote y brilla verde.
/// - error: tiembla suavemente (nunca rojo agresivo).
/// - dimmed: se desvanece (ya usada en la ronda).
class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.label,
    this.size = 130,
    this.color = 'sky',
    this.state = BigCardState.normal,
    this.onTap,
    this.fontSize = 64,
    this.labelColor,
  });

  /// Emoji o texto grande que muestra la tarjeta.
  final String label;

  /// Lado de la tarjeta en dp (mínimo recomendado 120).
  final double size;

  /// Nombre del color en [AppPalette].
  final String color;

  final BigCardState state;
  final VoidCallback? onTap;
  final double fontSize;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final base = AppPalette.of(color);
    final enabled = onTap != null && state != BigCardState.dimmed;

    final Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: state == BigCardState.dimmed
            ? Colors.grey.shade200
            : state == BigCardState.success
                ? AppPalette.green.withOpacity(.18)
                : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: state == BigCardState.success
              ? AppPalette.green
              : state == BigCardState.error
                  ? AppPalette.orange
                  : base.withOpacity(.5),
          width: 3,
        ),
        boxShadow: state == BigCardState.dimmed
            ? null
            : [
                BoxShadow(
                  color: state == BigCardState.success
                      ? AppPalette.green.withOpacity(.5)
                      : base.withOpacity(.35),
                  offset: const Offset(0, 5),
                  blurRadius: 0,
                ),
              ],
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              height: 1.1,
              color: labelColor ??
                  (state == BigCardState.dimmed
                      ? Colors.grey
                      : AppPalette.ink),
              fontWeight: FontWeight.w800,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
        ),
      ),
    );

    Widget result = content;
    if (state == BigCardState.error) {
      result = _Shaky(child: content);
    }
    if (state == BigCardState.success) {
      result = _Squash(child: result);
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: state == BigCardState.dimmed ? .45 : 1,
          child: result,
        ),
      ),
    );
  }
}

/// Temblor suave para el error (sin sustos).
class _Shaky extends StatefulWidget {
  const _Shaky({required this.child});

  final Widget child;

  @override
  State<_Shaky> createState() => _ShakyState();
}

class _ShakyState extends State<_Shaky> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final offset = Offset(
          (1 - t) * 6 * ((t * 8).round().isOdd ? 1 : -1),
          0,
        );
        return Transform.translate(offset: offset, child: child);
      },
      child: widget.child,
    );
  }
}

/// Aplaste con rebote al acertar (¡efecto aplastar!).
class _Squash extends StatefulWidget {
  const _Squash({required this.child});

  final Widget child;

  @override
  State<_Squash> createState() => _SquashState();
}

class _SquashState extends State<_Squash> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        // 1 → 0.82 → 1.06 → 1 con curva senoidal amortiguada.
        final scale = 1 +
            -0.18 * math.sin(t * math.pi * 2) * (1 - t) +
            0.06 * t * (1 - t) * 4 * (1 - t);
        return Transform.scale(scale: scale, child: child);
      },
      child: widget.child,
    );
  }
}