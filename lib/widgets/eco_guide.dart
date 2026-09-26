import 'package:flutter/material.dart';

/// El delfín EC0: personaje guía de toda la app.
///
/// Muestra la imagen assets/images/ECOico.png; si no carga
/// (asset faltante, error), cae al emoji 🐬 sin romper nada.
class EcoGuide extends StatelessWidget {
  const EcoGuide({super.key, this.size = 44});

  /// Tamaño en dp (ancho y alto).
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/ECOico.png',
      width: size,
      height: size,
      errorBuilder: (_, __, ___) => Text(
        '🐬',
        style: TextStyle(fontSize: size * .8),
      ),
    );
  }
}