import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../data/curriculum.dart';
import '../models/models.dart';
import '../services/progress_service.dart';
import '../services/tts_service.dart';
import '../screens/lesson_list_screen.dart';
import 'initiation_map_screen.dart';
import '../widgets/eco_guide.dart';

/// Menú principal: las secciones EC0 en ruta pedagógica.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = ProgressService.instance;
    const order = CurriculumOrder.ids;

    return Scaffold(
      backgroundColor: AppPalette.cream,
      body: SafeArea(
        child: Column(
          children: [
            _header(progress),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: Curriculum.sections.length + 1,
                itemBuilder: (context, i) {
                  if (i == Curriculum.sections.length) {
                    return _parentsFooter(context);
                  }
                  final section = Curriculum.sections[i];
                  final sectionId = order[i];
                  return ListenableBuilder(
                    listenable: progress,
                    builder: (context, _) => _sectionCard(
                      context,
                      section: section,
                      unlocked: progress.isSectionUnlocked(
                        sectionId,
                        orderedSectionIds: order,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(ProgressService progress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppPalette.sky, AppPalette.indigo],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const EcoGuide(size: 44),
              const SizedBox(width: 10),
              const Text(
                'EC0 · Aprende a leer',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ListenableBuilder(
            listenable: progress,
            builder: (context, _) => Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.22),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded,
                      color: AppPalette.yellow, size: 26),
                  const SizedBox(width: 6),
                  Text(
                    '${progress.totalStars} estrellas',
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required Ec0Section section,
    required bool unlocked,
  }) {
    final color = AppPalette.of(section.color);
    final progress = ProgressService.instance;
    final sectionId = CurriculumOrder.ids[section.kind.index];

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(unlocked ? .35 : .1),
              offset: const Offset(0, 5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: unlocked ? color : Colors.grey.shade400,
          borderRadius: BorderRadius.circular(26),
          child: InkWell(
            borderRadius: BorderRadius.circular(26),
                        onTap: () {
              if (!unlocked) {
                TtsService.instance.speakSentence(
                    'Primero termina la sección anterior.');
                return;
              }
              // Iniciación abre el mapa nuevo de 15 actividades.
              if (section.kind == SectionKind.initiation) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const InitiationMapScreen(),
                  ),
                );
                return;
              }
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LessonListScreen(section: section),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      unlocked ? section.emoji : '🔒',
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.title,
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          unlocked ? section.subtitle : 'Completa la sección anterior',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 15,
                            color: Colors.white.withOpacity(.85),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress.sectionProgress(sectionId),
                            minHeight: 8,
                            backgroundColor: Colors.white.withOpacity(.3),
                            valueColor:
                                const AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _parentsFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: TextButton.icon(
        onPressed: () => _showParentsDialog(context),
        icon: const Icon(Icons.family_restroom_rounded, size: 20),
        label: const Text(
          'Zona de padres',
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: TextButton.styleFrom(foregroundColor: Colors.black38),
      ),
    );
  }

  void _showParentsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Zona de padres'),
        content: const Text(
          'Aquí puedes desbloquear todas las secciones para usar la app '
          'libremente, sin esperar al progreso del niño.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          ListenableBuilder(
            listenable: ProgressService.instance,
            builder: (context, _) => TextButton(
              onPressed: () async {
                final newValue = !ProgressService.instance.unlockAll;
                await ProgressService.instance.setUnlockAll(newValue);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: Text(
                ProgressService.instance.unlockAll
                    ? 'Volver a bloquear'
                    : 'Desbloquear todo',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
