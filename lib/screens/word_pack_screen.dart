import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/models.dart';
import '../services/tts_service.dart';
import '../widgets/buttons.dart';
import '../widgets/common.dart';
import 'exercise_runner.dart';

/// Pantalla de un paquete de palabras largas ("Lee palabras 2").
/// Primero se leen las palabras (sílaba por sílaba), luego se practica
/// con ejercicios de ordenar sílabas y completar.
class WordPackScreen extends StatefulWidget {
  const WordPackScreen({super.key, required this.pack});

  final WordPack pack;

  @override
  State<WordPackScreen> createState() => _WordPackScreenState();
}

class _WordPackScreenState extends State<WordPackScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  WordPack get pack => widget.pack;
  Color get color => AppPalette.of(pack.color);

  @override
  void dispose() {
    _controller.dispose();
    TtsService.instance.stop();
    super.dispose();
  }

  Future<void> _readWord(WordItem w) async {
    for (final syl in w.syllables) {
      await TtsService.instance.speakSlow(syl);
    }
    await TtsService.instance.speak(w.word);
  }

  @override
  Widget build(BuildContext context) {
    final words = pack.words;
    return Scaffold(
      backgroundColor: AppPalette.cream,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(pack.title),
        backgroundColor: color.withOpacity(.15),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: words.length + 1,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  if (i == words.length) {
                    return _finalPage();
                  }
                  final w = words[i];
                  return Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        WordImage(image: w.image, emoji: w.emoji, size: 120),
                        const SizedBox(height: 18),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          children: [
                            for (final syl in w.syllables)
                              ChipButton(
                                label: syl,
                                color: color,
                                fontSize: 26,
                                onPressed: () =>
                                    TtsService.instance.speakSlow(syl),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SyllableWord(
                          syllables: w.syllables,
                          fontSize: 28,
                          tappable: true,
                        ),
                        const SizedBox(height: 16),
                        BigButton(
                          label: 'Leer todo',
                          color: AppPalette.green,
                          icon: Icons.play_arrow_rounded,
                          onPressed: () => _readWord(w),
                          fontSize: 18,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            _pager(words.length + 1),
          ],
        ),
      ),
    );
  }

  Widget _pager(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _page > 0
                ? () => _controller.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut)
                : null,
            icon: const Icon(Icons.arrow_back_rounded, size: 28),
            color: _page > 0 ? color : Colors.grey.shade300,
          ),
          Text(
            '${_page + 1} de $count',
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
            ),
          ),
          IconButton(
            onPressed: _page < count - 1
                ? () => _controller.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut)
                : null,
            icon: const Icon(Icons.arrow_forward_rounded, size: 28),
            color: _page < count - 1 ? color : Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  Widget _finalPage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎯', style: TextStyle(fontSize: 70)),
            const SizedBox(height: 12),
            Text(
              '¿A practicar?',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ordena sílabas y completa palabras',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 22),
            BigButton(
              label: '¡A jugar!',
              color: color,
              icon: Icons.sports_esports_rounded,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ExerciseRunnerScreen(
                      exercises: pack.exercises,
                      colorName: pack.color,
                      unitId: pack.id,
                      title: pack.title,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
