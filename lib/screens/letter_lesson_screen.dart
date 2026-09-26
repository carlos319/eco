import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/models.dart';
import '../services/progress_service.dart';
import '../services/tts_service.dart';
import '../widgets/buttons.dart';
import '../widgets/common.dart';
import '../widgets/feedback.dart';
import 'exercise_runner.dart';

/// Lección de una consonante, replicando el flujo del ppsx original:
/// portada → letra → escribimos → sonido → vocales → leamos → palabras →
/// ejercicio → fin.
class LetterLessonScreen extends StatefulWidget {
  const LetterLessonScreen({super.key, required this.lesson});

  final LetterLesson lesson;

  @override
  State<LetterLessonScreen> createState() => _LetterLessonScreenState();
}

class _LetterLessonScreenState extends State<LetterLessonScreen> {
  int _phase = 0;
  final int _totalPhases = 9;

  // Navegación interna de la parte de palabras.
  final PageController _wordsController = PageController();
  int _wordPage = 0;

  LetterLesson get lesson => widget.lesson;

  Color get color => AppPalette.of(lesson.color);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _announcePhase());
  }

  @override
  void dispose() {
    _wordsController.dispose();
    TtsService.instance.stop();
    super.dispose();
  }

  Future<void> _announcePhase() async {
    final l = lesson.letter;
    switch (_phase) {
      case 0:
        await TtsService.instance.speakSentence('La letra $l');
      case 1:
        await TtsService.instance
            .speakSentence('Esta es la letra $l. Toca las letras para escuchar.');
      case 2:
        await TtsService.instance
            .speakSentence('Con la $l escribimos estas palabras.');
      case 3:
        await TtsService.instance
            .speakSentence(lesson.soundHint ?? 'El sonido de la $l');
      case 4:
        await TtsService.instance.speakSentence(
            'Combinamos la $l con las vocales. Toca cada sílaba para escuchar.');
      case 5:
        await TtsService.instance.speakSentence('¡A leer!');
      case 6:
        await TtsService.instance.speakSentence(
            'Toca cada sílaba para leer la palabra. Después toca leer todo.');
      case 7:
        await TtsService.instance
            .speakSentence('Ejercicio. Evalúo mis logros.');
    }
  }

  void _nextPhase() async {
    if (_phase < _totalPhases - 1) {
      if (_phase == 6) {
        // Al terminar la lectura de palabras, la lección ya está "lograda".
        await ProgressService.instance.saveStars(lesson.id, 1);
      }
      setState(() => _phase++);
      _announcePhase();
    }
  }

  void _prevPhase() {
    if (_phase > 0) {
      setState(() => _phase--);
      _announcePhase();
    }
  }

  void _startExercises() async {
    TtsService.instance.stop();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExerciseRunnerScreen(
          exercises: lesson.exercises,
          colorName: lesson.color,
          unitId: lesson.id,
          title: 'La letra ${lesson.letter}',
        ),
      ),
    );
    if (mounted) {
      setState(() => _phase = 8);
      TtsService.instance.speakSentence('¡Has terminado la lección!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.cream,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('La letra ${lesson.letter}'),
        backgroundColor: color.withOpacity(.15),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _progressBar(),
            Expanded(child: _body()),
            _navBar(),
          ],
        ),
      ),
    );
  }

  Widget _progressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (_phase + 1) / _totalPhases,
                minHeight: 10,
                backgroundColor: Colors.black.withOpacity(.08),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${_phase + 1} / $_totalPhases',
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _navBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          if (_phase > 0)
            Expanded(
              child: BigButton(
                label: 'Atrás',
                color: Colors.grey.shade500,
                icon: Icons.arrow_back_rounded,
                onPressed: _prevPhase,
                fontSize: 18,
              ),
            ),
          if (_phase > 0) const SizedBox(width: 12),
          Expanded(
            flex: _phase == 0 ? 1 : 2,
            child: BigButton(
              label: _phase == _totalPhases - 1 ? 'Terminar' : 'Siguiente',
              color: color,
              icon: _phase == _totalPhases - 1
                  ? Icons.celebration_rounded
                  : Icons.arrow_forward_rounded,
              onPressed: _phase == _totalPhases - 1
                  ? () => Navigator.of(context).pop()
                  : _nextPhase,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    switch (_phase) {
      case 0:
        return _cover();
      case 1:
        return _letterView();
      case 2:
        return _writeView();
      case 3:
        return _soundView();
      case 4:
        return _combosView();
      case 5:
        return _readIntro();
      case 6:
        return _readView();
      case 7:
        return _exerciseView();
      default:
        return _doneView();
    }
  }

  // 0. Portada ---------------------------------------------------------------

  Widget _cover() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: color.withOpacity(.15),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${lesson.letter} ${lesson.letter.toUpperCase()}',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 84,
                fontWeight: FontWeight.w800,
                color: color,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'La letra ${lesson.letter}',
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: AppPalette.ink,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '¡Vamos a aprender una letra nueva!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 19,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // 1. La letra --------------------------------------------------------------

  Widget _letterView() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Así se escribe',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                _letterCard(lesson.letter, 'minúscula'),
                const SizedBox(width: 16),
                _letterCard(lesson.letter.toUpperCase(), 'MAYÚSCULA'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _letterCard(String letter, String label) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.1),
              offset: const Offset(0, 6),
              blurRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: () => TtsService.instance.speakSlow(letter),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  letter,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 110,
                    fontWeight: FontWeight.w800,
                    color: color,
                    height: 1.05,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 15,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 2. Con la letra escribimos ----------------------------------------------

  Widget _writeView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              'Con la "${lesson.letter}" escribimos:',
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppPalette.ink,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final w in lesson.pictureWords)
                  WordCard(word: w, highlightLetter: lesson.letter),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Toca cada palabra para escucharla',
              style: TextStyle(fontFamily: AppTheme.fontFamily,
                  fontSize: 15, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }

  // 3. El sonido -------------------------------------------------------------

  Widget _soundView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'El sonido de la letra',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => TtsService.instance.speakSlow(lesson.letter),
            child: Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: color.withOpacity(.15),
                shape: BoxShape.circle,
              ),
              child: Text(
                lesson.letter,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 90,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (lesson.soundHint != null)
            Text(
              lesson.soundHint!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 20,
                color: Colors.black54,
              ),
            ),
          const SizedBox(height: 22),
          SpeakerButton(
            size: 72,
            color: color,
            onTap: () => TtsService.instance.speakSlow(lesson.letter),
          ),
        ],
      ),
    );
  }

  // 4. Combinación con vocales -----------------------------------------------

  Widget _combosView() {
    const vowels = ['a', 'e', 'i', 'o', 'u'];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Combinación con las vocales',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: AppPalette.ink,
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final v in vowels)
                    _comboCard(lesson.letter, v),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _comboCard(String consonant, String vowel) {
    final syl = '$consonant$vowel';
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.12),
            offset: const Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => TtsService.instance.speakSlow(syl),
          child: Container(
            width: 150,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Column(
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.ink,
                    ),
                    children: [
                      TextSpan(text: consonant, style: TextStyle(color: color)),
                      const TextSpan(text: ' + '),
                      TextSpan(
                        text: vowel,
                        style: const TextStyle(color: AppPalette.pink),
                      ),
                      const TextSpan(text: ' ='),
                    ],
                  ),
                ),
                Text(
                  syl,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 46,
                    fontWeight: FontWeight.w800,
                    color: color,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 5. Portada de lectura ------------------------------------------------------

  Widget _readIntro() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📖', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 16),
          Text(
            '¡Leamos!',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Palabras con la nueva letra',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 20,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // 6. Palabras ----------------------------------------------------------------

  Widget _readView() {
    final words = lesson.words;
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _wordsController,
            itemCount: words.length,
            onPageChanged: (i) => setState(() => _wordPage = i),
            itemBuilder: (context, i) {
              final w = words[i];
              return Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    WordImage(image: w.image, emoji: w.emoji, size: 130),
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      children: [
                        for (final syl in w.syllables)
                          ChipButton(
                            label: syl,
                            color: color,
                            fontSize: 30,
                            onPressed: () =>
                                TtsService.instance.speakSlow(syl),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SyllableWord(
                      syllables: w.syllables,
                      highlightLetter: lesson.letter,
                      fontSize: 30,
                      tappable: true,
                    ),
                    const SizedBox(height: 18),
                    BigButton(
                      label: 'Leer todo',
                      color: AppPalette.green,
                      icon: Icons.play_arrow_rounded,
                      onPressed: () async {
                        for (final syl in w.syllables) {
                          await TtsService.instance.speakSlow(syl);
                        }
                        await TtsService.instance.speak(w.word);
                      },
                      fontSize: 18,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _wordPage > 0
                    ? () => _wordsController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut)
                    : null,
                icon: const Icon(Icons.arrow_back_rounded, size: 30),
                color: _wordPage > 0 ? color : Colors.grey.shade300,
              ),
              Text(
                '${_wordPage + 1} de ${words.length}',
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.black54,
                ),
              ),
              IconButton(
                onPressed: _wordPage < words.length - 1
                    ? () => _wordsController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut)
                    : null,
                icon: const Icon(Icons.arrow_forward_rounded, size: 30),
                color: _wordPage < words.length - 1
                    ? color
                    : Colors.grey.shade300,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 7. Ejercicio ---------------------------------------------------------------

  Widget _exerciseView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎯', style: TextStyle(fontSize: 76)),
            const SizedBox(height: 14),
            const Text(
              'Ejercicio',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 38,
                fontWeight: FontWeight.w800,
                color: AppPalette.ink,
              ),
            ),
            Text(
              'Evalúo mis logros',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 26),
            BigButton(
              label: '¡A jugar!',
              color: color,
              icon: Icons.sports_esports_rounded,
              onPressed: _startExercises,
            ),
          ],
        ),
      ),
    );
  }

  // 8. Fin ---------------------------------------------------------------------

  Widget _doneView() {
    return Celebration(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 80)),
              const SizedBox(height: 12),
              const Text(
                '¡Has terminado la lección!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: AppPalette.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'La letra ${lesson.letter} ya es tuya',
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 14),
              ListenableBuilder(
                listenable: ProgressService.instance,
                builder: (context, _) => StarsRow(
                  stars: ProgressService.instance.starsFor(lesson.id),
                  size: 40,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
