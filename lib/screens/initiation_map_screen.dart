import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/activity.dart';
import '../services/progress_service.dart';
import '../services/tts_service.dart';
import '../widgets/activity/stars_row.dart';
import 'activities/a01_igual_diferente.dart';
import 'activities/a02_que_le_falta.dart';
import 'activities/a03_izquierda_derecha.dart';
import 'activities/a04_aplasta_el_sonido.dart';
import 'activities/a05_cuantos_golpes.dart';
import 'activities/a06_rima_rima.dart';
import 'activities/a07_sonido_inicial.dart';
import 'activities/a08_traza_con_el_dedo.dart';
import 'activities/a09_dibuja_en_el_aire.dart';
import 'activities/a10_pinza_magica.dart';
import 'activities/a11_que_sigue.dart';
import 'activities/a12_ordena_mi_historia.dart';
import 'activities/a13_adivinador.dart';
import 'activities/a14_el_intruso.dart';
import 'activities/a15_libro_parlante.dart';
import '../widgets/eco_guide.dart';

/// Mapa de Iniciación: 4 niveles de aprestamiento con 15 actividades.
///
/// Los niveles se desbloquean en orden (terminar un nivel abre el
/// siguiente) y dentro del nivel las actividades avanzan en secuencia.
/// La lechuza Lía guía con la voz.
class InitiationMapScreen extends StatelessWidget {
  const InitiationMapScreen({super.key});

  /// Abre la actividad [spec].
  ///
  /// Abre la actividad [spec].
  Future<void> _open(BuildContext context, ActivitySpec spec) async {
    TtsService.instance.stop();

        // Pantallas ya integradas del módulo.
    Widget? screen;
    if (spec.id == 'a01') screen = A01IgualDiferente(spec: spec);
    if (spec.id == 'a02') screen = A02QueLeFalta(spec: spec);
    if (spec.id == 'a03') screen = A03IzquierdaDerecha(spec: spec);
    if (spec.id == 'a04') screen = A04AplastaElSonido(spec: spec);
    if (spec.id == 'a05') screen = A05CuantosGolpes(spec: spec);
    if (spec.id == 'a06') screen = A06RimaRima(spec: spec);
    if (spec.id == 'a07') screen = A07SonidoInicial(spec: spec);
    if (spec.id == 'a08') screen = A08TrazaConElDedo(spec: spec);
    if (spec.id == 'a09') screen = A09DibujaEnElAire(spec: spec);
    if (spec.id == 'a10') screen = A10PinzaMagica(spec: spec);
    if (spec.id == 'a11') screen = A11QueSigue(spec: spec);
    if (spec.id == 'a12') screen = A12OrdenaMiHistoria(spec: spec);
    if (spec.id == 'a13') screen = A13Adivinador(spec: spec);
    if (spec.id == 'a14') screen = A14ElIntruso(spec: spec);
    if (spec.id == 'a15') screen = A15LibroParlante(spec: spec);

    
    if (screen != null) {
      if (!context.mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => screen!),
      );
      return;
    }

    // Actividades pendientes de integrar (A02–A15).
    await TtsService.instance.speakSentence(
        '¡Muy pronto! Este juego todavía se está preparando.');
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${spec.code} · ${spec.name} — se conecta en el '
            'paso de las pantallas del módulo.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = ProgressService.instance;
    return Scaffold(
      backgroundColor: AppPalette.cream,
      appBar: AppBar(
        title: const Text('Iniciación · ¡A jugar!'),
        backgroundColor: AppPalette.sky.withOpacity(.15),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: progress,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              _guideCard(context, progress),
              for (var levelIndex = 0;
                  levelIndex < ActivityCatalog.levels.length;
                  levelIndex++)
                _levelSection(context, levelIndex),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  '🐬 EC0 te acompaña en cada juego',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 14,
                    color: AppPalette.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Saludo de la lechuza con el total de estrellas.
  Widget _guideCard(BuildContext context, ProgressService progress) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18, top: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppPalette.sky, width: 2.5),
      ),
      child: Row(
        children: [
          const EcoGuide(size: 56),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Hola! Soy Eco.',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppPalette.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Juega las actividades y gana estrellas.',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 15,
                    color: AppPalette.ink.withOpacity(.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Total de estrellas de iniciación.
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppPalette.yellow.withOpacity(.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded,
                    color: AppPalette.yellow, size: 22),
                const SizedBox(width: 4),
                Text(
                  '${progress.initiationStars}/75',
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppPalette.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _levelSection(BuildContext context, int levelIndex) {
    final level = ActivityCatalog.levels[levelIndex];
    final progress = ProgressService.instance;
    final unlocked = progress.isActivityLevelUnlocked(levelIndex);
    final activities = ActivityCatalog.byLevel(level);
    final color = AppPalette.of(level.color);
    final allDone =
        activities.every((a) => progress.activityStarsFor(a.id) == 5);
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rótulo del nivel.
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: unlocked ? color : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(level.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  'Nivel ${levelIndex + 1} · ${level.name}',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppPalette.textOn(level.color),
                  ),
                ),
                const SizedBox(width: 8),
                if (allDone) const Text('🏆', style: TextStyle(fontSize: 16)),
                if (!unlocked) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.lock_rounded,
                      size: 16, color: Colors.white),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Actividades del nivel.
          ...List.generate(activities.length, (i) {
            final spec = activities[i];
            final canOpen = progress.isActivityUnlocked(levelIndex, i);
            final stars = progress.activityStarsFor(spec.id);
            return _activityCard(
              context,
              spec: spec,
              unlocked: canOpen,
              stars: stars,
            );
          }),
        ],
      ),
    );
  }

  Widget _activityCard(
    BuildContext context, {
    required ActivitySpec spec,
    required bool unlocked,
    required int stars,
  }) {
    final color = AppPalette.of(spec.level.color);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Opacity(
        opacity: unlocked ? 1 : .55,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color:
                  unlocked ? color.withOpacity(.45) : Colors.grey.shade300,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: unlocked
                    ? color.withOpacity(.22)
                    : Colors.black.withOpacity(.04),
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () {
                if (unlocked) {
                  _open(context, spec);
                } else {
                  TtsService.instance.speakSentence(
                    'Gana una estrella en la actividad anterior para '
                    'abrir esta.',
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: unlocked
                            ? color.withOpacity(.15)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        unlocked ? spec.emoji : '🔒',
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 1),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  spec.code,
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: color,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  spec.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w700,
                                    color: AppPalette.ink,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ActivityStarsRow(stars: stars, total: 5, size: 20),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppPalette.ink, size: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}