import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

/// Fila de estrellas del módulo de Iniciación (hasta 5, una por ronda).
///
/// Es propia del módulo: las `StarsRow` de la app principal muestran
/// las 0-3 estrellas de las lecciones; las actividades de aprestamiento
/// conceden hasta 5.
class ActivityStarsRow extends StatelessWidget {
  const ActivityStarsRow({
    super.key,
    required this.stars,
    this.total = 5,
    this.size = 22,
  });

  final int stars;
  final int total;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final filled = i < stars;
        return Icon(
          filled ? Icons.star_rounded : Icons.star_outline_rounded,
          color: filled ? AppPalette.yellow : Colors.grey.shade400,
          size: size,
        );
      }),
    );
  }
}