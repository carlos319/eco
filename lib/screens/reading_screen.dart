import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/models.dart';
import '../services/progress_service.dart';
import '../services/tts_service.dart';
import '../widgets/buttons.dart';
import '../widgets/common.dart';
import '../widgets/feedback.dart';

/// Una lectura completa con páginas, lectura en voz alta y subrayado
/// de la palabra actual (karaoke).
class ReadingScreen extends StatefulWidget {
  const ReadingScreen({super.key, required this.reading});

  final Reading reading;

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  int _page = 0;
  int _activeWord = -1;
  bool _reading = false;
  bool _done = false;

  Reading get reading => widget.reading;
  Color get color => AppPalette.of(reading.color);

  ReadingPage get page => reading.pages[_page];

  /// Palabras de la página actual con su línea de origen.
  List<(int line, String word)> get pageWords {
    final out = <(int, String)>[];
    for (var l = 0; l < page.lines.length; l++) {
      for (final w in page.lines[l].split(' ')) {
        if (w.isNotEmpty) out.add((l, w));
      }
    }
    return out;
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }

  Future<void> _readPage({bool wordByWord = true}) async {
    if (_reading) return;
    setState(() => _reading = true);
    if (wordByWord) {
      for (var i = 0; i < pageWords.length; i++) {
        if (!mounted) return;
        setState(() => _activeWord = i);
        await TtsService.instance.speak(pageWords[i].$2);
      }
      setState(() => _activeWord = -1);
      await TtsService.instance.speakSentence(page.text);
    } else {
      await TtsService.instance.speakSentence(page.text);
    }
    if (mounted) setState(() => _reading = false);
  }

  Future<void> _next() async {
    if (_page < reading.pages.length - 1) {
      TtsService.instance.stop();
      setState(() {
        _page++;
        _activeWord = -1;
      });
    } else {
      await ProgressService.instance.saveStars(reading.id, 1);
      TtsService.instance.speakSentence('¡Fin del cuento! Muy bien.');
      setState(() => _done = true);
    }
  }

  void _prev() {
    if (_page > 0) {
      TtsService.instance.stop();
      setState(() {
        _page--;
        _activeWord = -1;
        _done = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return Celebration(
        child: Scaffold(
          backgroundColor: AppPalette.cream,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(reading.title),
            backgroundColor: color.withOpacity(.15),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(reading.emoji, style: const TextStyle(fontSize: 76)),
                const SizedBox(height: 12),
                const Text(
                  '¡Fin del cuento!',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppPalette.ink,
                  ),
                ),
                const SizedBox(height: 14),
                ListenableBuilder(
                  listenable: ProgressService.instance,
                  builder: (context, _) => StarsRow(
                    stars: ProgressService.instance.starsFor(reading.id),
                    size: 40,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final words = pageWords;
    return Scaffold(
      backgroundColor: AppPalette.cream,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(reading.title),
        backgroundColor: color.withOpacity(.15),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'Página ${_page + 1} de ${reading.pages.length}',
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black45,
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.08),
                        offset: const Offset(0, 6),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var l = 0; l < page.lines.length; l++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Wrap(
                              spacing: 7,
                              runSpacing: 4,
                              children: [
                                for (var i = 0; i < words.length; i++)
                                  if (words[i].$1 == l)
                                    _wordSpan(i, words[i].$2),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: BigButton(
                      label: 'Leer conmigo',
                      color: color,
                      icon: Icons.auto_stories_rounded,
                      onPressed:
                          _reading ? null : () => _readPage(wordByWord: true),
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: BigButton(
                      label: 'Escuchar',
                      color: AppPalette.indigo,
                      icon: Icons.graphic_eq_rounded,
                      onPressed: _reading
                          ? null
                          : () => _readPage(wordByWord: false),
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (_page > 0)
                    Expanded(
                      child: BigButton(
                        label: 'Atrás',
                        color: Colors.grey.shade500,
                        icon: Icons.arrow_back_rounded,
                        onPressed: _prev,
                        fontSize: 17,
                      ),
                    ),
                  if (_page > 0) const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: BigButton(
                      label: _page == reading.pages.length - 1
                          ? 'Terminar'
                          : 'Página siguiente',
                      color: AppPalette.green,
                      icon: Icons.arrow_forward_rounded,
                      onPressed: _next,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _wordSpan(int index, String word) {
    final isActive = index == _activeWord;
    return GestureDetector(
      onTap: _reading
          ? null
          : () async {
              setState(() => _activeWord = index);
              await TtsService.instance.speak(word);
              if (mounted) setState(() => _activeWord = -1);
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(.25) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          word,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 27,
            fontWeight: FontWeight.w600,
            color: isActive ? AppPalette.ink : AppPalette.ink.withOpacity(.9),
            height: 1.3,
          ),
        ),
      ),
    );
  }
}
