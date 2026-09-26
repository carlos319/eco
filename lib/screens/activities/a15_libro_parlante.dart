import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/activity.dart';
import '../../services/audio_service.dart';
import '../../services/tts_service.dart';
import '../../widgets/activity/activity_host.dart';

/// A15 · Mi primer libro parlante — la primera frase "leída".
///
/// Se arrastra cada palabra a su hueco; al completarla, el libro
/// la lee completo en voz alta: la magia de leer.
class A15LibroParlante extends StatelessWidget {
  const A15LibroParlante({super.key, required this.spec});

  final ActivitySpec spec;

  static const List<_Round> _rounds = [
    _Round(sentence: 'El gato duerme', emoji: '🐱😴'),
    _Round(sentence: 'La luna brilla', emoji: '🌙✨'),
    _Round(sentence: 'El pez nada', emoji: '🐟💦'),
    _Round(sentence: 'El sol calienta', emoji: '☀️🔥'),
    _Round(sentence: 'El perro corre', emoji: '🐶💨'),
  ];

  @override
  Widget build(BuildContext context) {
    return ActivityHost(
      spec: spec,
      roundCount: _rounds.length,
      roundSpeech: (round) =>
          '¡Vas a leer tu primera frase! Arrastra las palabras a su lugar.',
      roundBuilder: (context, round, controller) => _RoundView(
        key: ValueKey(round),
        round: _rounds[round],
        controller: controller,
      ),
    );
  }
}

class _Round {
  const _Round({required this.sentence, required this.emoji});

  final String sentence;
  final String emoji;
}

class _RoundView extends StatefulWidget {
  const _RoundView({
    super.key,
    required this.round,
    required this.controller,
  });

  final _Round round;
  final ActivityController controller;

  @override
  State<_RoundView> createState() => _RoundViewState();
}

class _RoundViewState extends State<_RoundView> {
  late final List<String> _words;
  late final List<String> _shuffled;
  final Set<String> _placed = {};

  @override
  void initState() {
    super.initState();
    _words = widget.round.sentence.split(' ');
    _shuffled = [..._words]..shuffle();
  }

  Future<void> _onPlaced(String word) async {
    if (_placed.contains(word)) return;
    _placed.add(word);
    await AudioService.instance.pop();
    if (mounted) setState(() {});
    if (_placed.length == _words.length) {
      // ✨ LA MAGIA: el libro lee la frase completa.
      await AudioService.instance.star();
      await TtsService.instance.speakSentence(
          '¡Míralo, lo leíste! ${widget.round.sentence}.');
      widget.controller.roundCorrect(phrase: '¡Estás leyendo!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // El libro: escena + huecos para las palabras.
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppPalette.purple, width: 3),
          ),
          child: Column(
            children: [
              Text(widget.round.emoji, style: const TextStyle(fontSize: 54)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final w in _words)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: DragTarget<String>(
                        onWillAccept: (data) => data == w,
                        onAccept: (data) => _onPlaced(data),
                        builder: (context, candidates, _) {
                          final done = _placed.contains(w);
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 84,
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: done
                                  ? AppPalette.green.withOpacity(.15)
                                  : candidates.isNotEmpty
                                      ? AppPalette.green.withOpacity(.25)
                                      : AppPalette.cream,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: done
                                    ? AppPalette.green
                                    : candidates.isNotEmpty
                                        ? AppPalette.green
                                        : AppPalette.sky,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              done ? w : '',
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppPalette.ink,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        // Palabras desordenadas y arrastrables.
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            for (final w in _shuffled)
              if (!_placed.contains(w))
                Draggable<String>(
                  data: w,
                  feedback: _wordChip(w, dragging: true),
                  childWhenDragging: Opacity(
                    opacity: .25,
                    child: _wordChip(w),
                  ),
                  child: _wordChip(w),
                ),
          ],
        ),
      ],
    );
  }

  Widget _wordChip(String w, {bool dragging = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: dragging ? AppPalette.purple : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.purple, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppPalette.purple.withOpacity(.3),
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(
        w,
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: dragging ? Colors.white : AppPalette.ink,
        ),
      ),
    );
  }
}