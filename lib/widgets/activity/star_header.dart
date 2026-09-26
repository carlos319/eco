import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/activity.dart';
import '../common.dart';
import 'stars_row.dart';

/// Cabecera de actividad: volver · título · ⭐ x/5 · repetir audio.
class StarHeader extends StatelessWidget {
  const StarHeader({
    super.key,
    required this.spec,
    required this.stars,
    required this.total,
    required this.onBack,
    required this.onRepeat,
  });

  final ActivitySpec spec;
  final int stars;
  final int total;
  final VoidCallback onBack;
  final VoidCallback onRepeat;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppPalette.of(spec.level.color).withOpacity(.25),
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Volver al mapa
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            iconSize: 30,
            color: AppPalette.ink,
            tooltip: 'Volver al mapa',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          ),
          // Personaje + nombre de la actividad
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(spec.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    spec.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppPalette.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Estrellas x/5
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: ActivityStarsRow(stars: stars, total: total, size: 22),
          ),
          // Repetir instrucción
          SpeakerButton(onTap: onRepeat, size: 44),
        ],
      ),
    );
  }
}