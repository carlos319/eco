import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/models.dart';
import '../services/progress_service.dart';
import '../services/tts_service.dart';
import '../widgets/buttons.dart';
import '../widgets/common.dart';
import '../widgets/feedback.dart';

/// Lectura guiada de una frase palabra por palabra (estilo karaoke).
class PhraseScreen extends StatefulWidget {
  const PhraseScreen({super.key, required this.pack});

  final PhrasePack pack;

  @override
  State<PhraseScreen> createState() => _PhraseScreenState();
}

class _PhraseScreenState extends State<PhraseScreen> {
  int _phraseIndex = 0;
  int _wordIndex = -1; // -1: ninguna resaltada
  bool _reading = false;
  bool _done = false;

  PhrasePack get pack => widget.pack;
  Color get color => AppPalette.of(pack.color);

  PhraseItem get phrase => pack.phrases[_phraseIndex];

  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }

  Future<void> _readPhrase({bool wordByWord = true}) async {
    if (_reading) return;
    setState(() => _reading = true);
    if (wordByWord) {
      for (var i = 0; i < phrase.words.length; i++) {
        if (!mounted) return;
        setState(() => _wordIndex = i);
        await TtsService.instance.speak(phrase.words[i]);
      }
      setState(() => _wordIndex = -1);
      await TtsService.instance.speakSentence(phrase.text);
    } else {
      await TtsService.instance.speakSentence(phrase.text);
    }
    if (mounted) setState(() => _reading = false);
  }

  Future<void> _next() async {
    if (_phraseIndex < pack.phrases.length - 1) {
      TtsService.instance.stop();
      setState(() {
        _phraseIndex++;
        _wordIndex = -1;
      });
    } else {
      await ProgressService.instance.saveStars(pack.id, 1);
      TtsService.instance.speakSentence('¡Has terminado el paquete de frases!');
      setState(() => _done = true);
    }
  }

  void _prev() {
    if (_phraseIndex > 0) {
      TtsService.instance.stop();
      setState(() {
        _phraseIndex--;
        _wordIndex = -1;
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
            title: Text(pack.title),
            backgroundColor: color.withOpacity(.15),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🏆', style: TextStyle(fontSize: 80)),
                const SizedBox(height: 12),
                const Text(
                  '¡Frases leídas!',
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
                    stars: ProgressService.instance.starsFor(pack.id),
                    size: 40,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'Frase ${_phraseIndex + 1} de ${pack.phrases.length}',
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.black45,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(22),
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
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (var i = 0; i < phrase.words.length; i++)
                          _wordChip(i),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: BigButton(
                      label: 'Palabra a palabra',
                      color: color,
                      icon: Icons.menu_book_rounded,
                      onPressed: _reading ? null : () => _readPhrase(),
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: BigButton(
                      label: 'Frase completa',
                      color: AppPalette.indigo,
                      icon: Icons.graphic_eq_rounded,
                      onPressed: _reading
                          ? null
                          : () => _readPhrase(wordByWord: false),
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  if (_phraseIndex > 0)
                    Expanded(
                      child: BigButton(
                        label: 'Atrás',
                        color: Colors.grey.shade500,
                        icon: Icons.arrow_back_rounded,
                        onPressed: _prev,
                        fontSize: 17,
                      ),
                    ),
                  if (_phraseIndex > 0) const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: BigButton(
                      label: _phraseIndex == pack.phrases.length - 1
                          ? 'Terminar'
                          : 'Siguiente frase',
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

  Widget _wordChip(int i) {
    final isActive = i == _wordIndex;
    return GestureDetector(
      onTap: _reading
          ? null
          : () async {
              setState(() => _wordIndex = i);
              await TtsService.instance.speak(phrase.words[i]);
              if (mounted) setState(() => _wordIndex = -1);
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? color : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Text(
          phrase.words[i],
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: isActive ? Colors.white : AppPalette.ink,
            height: 1.15,
          ),
        ),
      ),
    );
  }
}
