import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../eco_guide.dart';

/// Burbuja del personaje guía (el delfín EC0 🐬).
///
/// Muestra la instrucción actual (decorativa para adultos). Las
/// instrucciones reales van por voz con TTS.
class GuideBubble extends StatelessWidget {
  const GuideBubble({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EcoGuide(size: 40),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppPalette.sky, width: 2),
              ),
              child: Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14.5,
                  height: 1.2,
                  color: AppPalette.ink.withOpacity(.85),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}