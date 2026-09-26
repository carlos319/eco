import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../data/curriculum.dart';
import '../models/models.dart';
import '../services/progress_service.dart';
import '../services/tts_service.dart';
import '../screens/letter_lesson_screen.dart';
import '../screens/phrase_screen.dart';
import '../screens/reading_screen.dart';
import '../screens/slideshow_lesson_screen.dart';
import '../screens/word_pack_screen.dart';
import '../widgets/common.dart';
 
/// Lista de unidades (lecciones) de una sección, con candados y estrellas.
class LessonListScreen extends StatelessWidget {
  const LessonListScreen({super.key, required this.section});

  final Ec0Section section;

  Color get color => AppPalette.of(section.color);

  @override
  Widget build(BuildContext context) {
   final progress = ProgressService.instance;
// Normaliza el id de sección al usado por CurriculumOrder.
   final sectionId = CurriculumOrder.ids[section.kind.index];
   final unitIds = Curriculum.unitIdsBySection()[sectionId] ?? [];
   final units = _units();
   
    return Scaffold(
      backgroundColor: AppPalette.cream,
      appBar: AppBar(
        title: Text(section.title),
        backgroundColor: color.withOpacity(.15),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress.sectionProgress(sectionId),
                        minHeight: 12,
                        backgroundColor: Colors.black.withOpacity(.08),
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.star_rounded,
                      color: AppPalette.yellow, size: 22),
                  const SizedBox(width: 2),
                  ListenableBuilder(
                    listenable: progress,
                    builder: (context, _) => Text(
                      '${progress.sectionStars(sectionId)}',
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppPalette.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: units.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final unlocked = progress.isUnitUnlocked(sectionId, i);
                  return ListenableBuilder(
                    listenable: progress,
                    builder: (context, _) => _unitCard(
                      context,
                      index: i,
                      title: units[i].$1,
                      subtitle: units[i].$2,
                      emoji: units[i].$3,
                      unlocked: progress.isUnitUnlocked(sectionId, i),
                      stars: progress.starsFor(unitIds[i]),
                      onTap: () => _openUnit(context, i, unlocked),
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

  /// (título, subtítulo, emoji) de cada unidad.
  List<(String, String, String)> _units() {
    switch (section.kind) {
      case SectionKind.initiation:
        return [
          for (final l in Curriculum.initiation())
            (l.title, 'Lección guiada', '✏️'),
        ];
      case SectionKind.vowels:
        return [
          for (final l in Curriculum.vowels())
            (l.title, 'Lección de vocal', '🅰️'),
        ];
      case SectionKind.words1:
        return [
          for (final l in Curriculum.letters())
            (
              'La letra ${l.letter}',
              'Sílabas: ${l.syllables.join(" · ")}',
              l.letter.toUpperCase() + l.letter
            ),
        ];
      case SectionKind.words2:
        return [
          for (final p in Curriculum.wordPacks())
            (p.title, '${p.words.length} palabras largas', '🚀'),
        ];
      case SectionKind.phrases:
        return [
          for (final p in Curriculum.phrasePacks())
            (p.title, '${p.phrases.length} frases', '✏️'),
        ];
      case SectionKind.readings:
        return [
          for (final r in Curriculum.readings())
            (r.title, '${r.pages.length} páginas', r.emoji),
        ];
    }
  }

  Future<void> _openUnit(BuildContext context, int index, bool unlocked) async {
    if (!unlocked) {
      TtsService.instance.speakSentence(
          'Completa la lección anterior para desbloquear.');
      return;
    }
    TtsService.instance.stop();
    Widget screen = switch (section.kind) {
      SectionKind.initiation => SlideshowLessonScreen(
          lesson: Curriculum.initiation()[index]),
      SectionKind.vowels =>
        SlideshowLessonScreen(lesson: Curriculum.vowels()[index]),
      SectionKind.words1 =>
        LetterLessonScreen(lesson: Curriculum.letters()[index]),
      SectionKind.words2 => WordPackScreen(pack: Curriculum.wordPacks()[index]),
      SectionKind.phrases => PhraseScreen(pack: Curriculum.phrasePacks()[index]),
      SectionKind.readings => ReadingScreen(reading: Curriculum.readings()[index]),
    };
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Widget _unitCard(
    BuildContext context, {
    required int index,
    required String title,
    required String subtitle,
    required String emoji,
    required bool unlocked,
    required int stars,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: unlocked ? 1 : .55,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: unlocked ? color.withOpacity(.4) : Colors.grey.shade200,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color.withOpacity(.15),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: unlocked
                        ? Text(
                            emoji,
                            style: const TextStyle(fontSize: 26),
                          )
                        : const Icon(Icons.lock_rounded,
                            color: Colors.black38, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppPalette.ink,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 14,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  unlocked
                      ? StarsRow(stars: stars, size: 22)
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
