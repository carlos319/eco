import 'dart:math';

import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/models.dart';
import '../services/progress_service.dart';
import '../services/tts_service.dart';
import '../widgets/buttons.dart';
import '../widgets/common.dart';
import '../widgets/feedback.dart';

/// Ejecuta una serie de ejercicios con feedback "¡MUY BIEN!" / "No es esa"
/// (como el ppsx original) y guarda las estrellas al terminar.
class ExerciseRunnerScreen extends StatefulWidget {
  const ExerciseRunnerScreen({
    super.key,
    required this.exercises,
    required this.colorName,
    required this.unitId,
    this.title = 'Ejercicio',
  });

  final List<Exercise> exercises;
  final String colorName;
  final String unitId;
  final String title;

  @override
  State<ExerciseRunnerScreen> createState() => _ExerciseRunnerScreenState();
}

class _ExerciseRunnerScreenState extends State<ExerciseRunnerScreen> {
  int _index = 0;
  int _errors = 0;
  bool _finished = false;
  int _earnedStars = 0;

  // Estado por ejercicio.
  bool _showOverlay = false;
  bool _lastWasCorrect = false;
  String _overlayMessage = '';

  // Estado de ejercicios concretos.
  final List<int> _selectedFind = [];
  final List<String> _formedSyllables = [];
  List<String> _shuffledOptions = const [];
  final Random _random = Random();

  Exercise get _current => widget.exercises[_index];

  Color get _color => AppPalette.of(widget.colorName);

  @override
  void initState() {
    super.initState();
    _shuffleForCurrent();
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakQuestion());
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }

  void _shuffleForCurrent() {
    final e = _current;
    if (e.type == ExerciseType.orderSyllables) {
      final list = [...e.syllables];
      // Mezcla garantizando que no quede igual al orden correcto.
      for (var attempt = 0; attempt < 6; attempt++) {
        list.shuffle(_random);
        if (list.length < 2 || !_listEquals(list, e.syllables)) break;
      }
      _shuffledOptions = list;
      _formedSyllables.clear();
    } else if (e.type == ExerciseType.pickWordForImage ||
        e.type == ExerciseType.completeWord ||
        e.type == ExerciseType.chooseVisual) {
      final list = [...e.options];
      for (var attempt = 0; attempt < 6; attempt++) {
        list.shuffle(_random);
        if (list.length < 2) break;
        final correctOpt = e.type == ExerciseType.completeWord
            ? e.syllables[e.missingIndex]
            : (e.type == ExerciseType.chooseVisual
                ? e.options[e.correctIndex]
                : e.word!);
        if (list.length < 2 || list.first != correctOpt) break;
      }
      _shuffledOptions = list;
    } else {
      _shuffledOptions = e.options;
    }
    _selectedFind.clear();
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<void> _speakQuestion() async {
    await TtsService.instance.speakSentence(_current.question);
  }

  void _answer(bool correct, {String? successMessage}) {
    setState(() {
      _lastWasCorrect = correct;
      _showOverlay = true;
      _overlayMessage =
          correct ? (successMessage ?? '¡Lo lograste!') : 'Inténtalo otra vez';
    });
    if (correct) {
      TtsService.instance.speakSentence('¡Muy bien!');
    } else {
      _errors++;
      TtsService.instance.speakSentence('No es esa. Inténtalo otra vez');
    }
  }

  void _continue() {
    if (_lastWasCorrect) {
      if (_index + 1 < widget.exercises.length) {
        setState(() {
          _index++;
          _showOverlay = false;
        });
        _shuffleForCurrent();
        _speakQuestion();
      } else {
        _finish();
      }
    } else {
      setState(() => _showOverlay = false);
    }
  }

  Future<void> _finish() async {
    final stars = _errors == 0
        ? 3
        : _errors <= 2
            ? 2
            : 1;
    await ProgressService.instance.saveStars(widget.unitId, stars);
    setState(() {
      _showOverlay = false;
      _finished = true;
      _earnedStars = stars;
    });
    TtsService.instance.speakSentence(
      '¡Has terminado el ejercicio! Ganaste ${stars == 1 ? 'una estrella' : '$stars estrellas'}.',
    );
  }

  void _restart() {
    setState(() {
      _index = 0;
      _errors = 0;
      _finished = false;
      _showOverlay = false;
    });
    _shuffleForCurrent();
    _speakQuestion();
  }

  // ------------------------------------------------------------------ UI

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: BackButton(
          onPressed: () {
            TtsService.instance.stop();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: _finished
            ? _buildFinish()
            : Column(
                children: [
                  _buildHeader(),
                  Expanded(child: _buildExercise()),
                ],
              ),
      ),
    );

    if (_showOverlay) {
      return Stack(
        children: [
          scaffold,
          FeedbackOverlay(
            correct: _lastWasCorrect,
            message: _overlayMessage,
            onContinue: _continue,
          ),
        ],
      );
    }
    if (_finished) {
      return Celebration(child: scaffold);
    }
    return scaffold;
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Evalúo mis logros',
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppPalette.ink,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (_index + 1) / widget.exercises.length,
                    minHeight: 12,
                    backgroundColor: Colors.black.withOpacity(.08),
                    valueColor: AlwaysStoppedAnimation(_color),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_index + 1} / ${widget.exercises.length}',
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.ink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            _current.question,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: AppPalette.ink,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SpeakerButton(
          size: 44,
          color: _color,
          onTap: _speakQuestion,
        ),
      ],
    );
  }

  Widget _buildExercise() {
    final e = _current;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildQuestion(),
          const SizedBox(height: 18),
          switch (e.type) {
            ExerciseType.pickWordForImage => _buildPickWord(e),
            ExerciseType.orderSyllables => _buildOrderSyllables(e),
            ExerciseType.completeWord => _buildCompleteWord(e),
            ExerciseType.findLetterWords => _buildFindLetter(e),
            ExerciseType.chooseVisual => _buildChooseVisual(e),
          },
        ],
      ),
    );
  }

  // 1. Imagen + opciones de palabra ------------------------------------------

  Widget _buildPickWord(Exercise e) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.08),
                offset: const Offset(0, 6),
                blurRadius: 14,
              ),
            ],
          ),
          child: WordImage(image: e.image, emoji: e.emoji, size: 190),
        ),
        const SizedBox(height: 22),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final opt in _shuffledOptions)
              ChipButton(
                label: opt,
                color: _color,
                fontSize: 24,
                onPressed: () =>
                    _answer(opt == e.word, successMessage: '$opt ✓'),
              ),
          ],
        ),
      ],
    );
  }

  // 2. Ordenar sílabas --------------------------------------------------------

  Widget _buildOrderSyllables(Exercise e) {
    final slots = List.generate(e.syllables.length, (i) {
      final filled = i < _formedSyllables.length;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: filled ? _color.withOpacity(.15) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: filled ? _color : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Text(
          filled ? _formedSyllables[i] : '?',
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: filled ? _color : Colors.grey.shade400,
          ),
        ),
      );
    });

    return Column(
      children: [
        if (e.image != null || e.emoji != null)
          WordImage(image: e.image, emoji: e.emoji, size: 120),
        const SizedBox(height: 14),
        Wrap(
          alignment: WrapAlignment.center,
          children: slots,
        ),
        const SizedBox(height: 26),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final syl in _shuffledOptions)
              if (!_formedSyllables.contains(syl) ||
                  _countIn(_formedSyllables, syl) <
                      _countIn(e.syllables, syl))
              ChipButton(
                label: syl,
                color: AppPalette.purple,
                fontSize: 26,
                onPressed: () => _onSyllableTap(e, syl),
              ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          e.word ?? '',
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black45,
          ),
        ),
      ],
    );
  }

  int _countIn(List<String> list, String value) =>
      list.where((v) => v == value).length;

  Future<void> _onSyllableTap(Exercise e, String syl) async {
    final nextIndex = _formedSyllables.length;
    if (e.syllables[nextIndex] == syl) {
      await TtsService.instance.speakSlow(syl);
      setState(() => _formedSyllables.add(syl));
      if (_formedSyllables.length == e.syllables.length) {
        await Future.delayed(const Duration(milliseconds: 400));
        await TtsService.instance.speak(e.word!);
        _answer(true, successMessage: '¡Formaste la palabra ${e.word}!');
      }
    } else {
      _answer(false);
    }
  }

  // 3. Completar sílaba -------------------------------------------------------

  Widget _buildCompleteWord(Exercise e) {
    final parts = <Widget>[];
    for (var i = 0; i < e.syllables.length; i++) {
      final isMissing = i == e.missingIndex;
      parts.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isMissing ? AppPalette.yellow.withOpacity(.25) : null,
            borderRadius: BorderRadius.circular(14),
            border: isMissing
                ? Border.all(color: AppPalette.yellowDark, width: 2.5)
                : null,
          ),
          child: Text(
            isMissing ? '__' : e.syllables[i],
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 38,
              fontWeight: FontWeight.w700,
              color: isMissing ? AppPalette.yellowDark : AppPalette.ink,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        if (e.image != null || e.emoji != null)
          WordImage(image: e.image, emoji: e.emoji, size: 120),
        const SizedBox(height: 14),
        Wrap(alignment: WrapAlignment.center, children: parts),
        const SizedBox(height: 26),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final opt in _shuffledOptions)
              ChipButton(
                label: opt,
                color: _color,
                fontSize: 26,
                onPressed: () {
                  final correct = opt == e.syllables[e.missingIndex];
                  _answer(correct,
                      successMessage:
                          'La palabra es ${e.word}');
                },
              ),
          ],
        ),
      ],
    );
  }

  // 4. Identificar palabras con la letra -------------------------------------

  Widget _buildFindLetter(Exercise e) {
    final letter = (e.letter ?? '').toLowerCase();
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
          decoration: BoxDecoration(
            color: _color.withOpacity(.15),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            '${e.letter!.toUpperCase()} ${e.letter!}',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: _color,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            for (var i = 0; i < e.options.length; i++)
              ChipButton(
                label: e.options[i],
                color: _color,
                fontSize: 22,
                selected: _selectedFind.contains(i),
                onPressed: () async {
                  await TtsService.instance.speak(e.options[i]);
                  setState(() {
                    if (_selectedFind.contains(i)) {
                      _selectedFind.remove(i);
                    } else {
                      _selectedFind.add(i);
                    }
                  });
                },
              ),
          ],
        ),
        const SizedBox(height: 26),
        BigButton(
          label: '¡Listo!',
          color: AppPalette.green,
          icon: Icons.check_rounded,
          onPressed: _selectedFind.isEmpty ? null : () {
            final correctSet = <int>{
              for (var i = 0; i < e.options.length; i++)
                if (e.options[i].toLowerCase().contains(letter)) i,
            };
            final ok = correctSet.length == _selectedFind.length &&
                correctSet.containsAll(_selectedFind);
            _answer(ok,
                successMessage: '¡Encontraste todas las palabras con $letter!');
          },
        ),
      ],
    );
  }

  // 5. Pregunta visual (emojis) ----------------------------------------------

  Widget _buildChooseVisual(Exercise e) {
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 22,
          runSpacing: 22,
          children: [
            for (var i = 0; i < e.options.length; i++)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.15),
                      offset: const Offset(0, 5),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => _answer(i == e.correctIndex),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        e.options[i],
                        style: const TextStyle(fontSize: 64),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // Pantalla final ------------------------------------------------------------

  Widget _buildFinish() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎊', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 8),
            const Text(
              '¡Has terminado el ejercicio!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppPalette.ink,
              ),
            ),
            const SizedBox(height: 14),
            StarsRow(stars: _earnedStars, size: 44),
            const SizedBox(height: 30),
            BigButton(
              label: 'Repetir',
              color: _color,
              icon: Icons.refresh_rounded,
              onPressed: _restart,
            ),
            const SizedBox(height: 14),
            BigButton(
              label: 'Terminar',
              color: AppPalette.green,
              icon: Icons.celebration_rounded,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
