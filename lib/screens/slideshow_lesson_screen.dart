import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/models.dart';
import '../services/progress_service.dart';
import '../services/tts_service.dart';
import '../widgets/buttons.dart';
import '../widgets/common.dart';
import '../widgets/feedback.dart';
import 'exercise_runner.dart';

/// Lección tipo presentación con pasos (Iniciación y Vocales).
/// Algunos pasos incluyen ejercicios interactivos incrustados.
class SlideshowLessonScreen extends StatefulWidget {
  const SlideshowLessonScreen({super.key, required this.lesson});

  final SlideshowLesson lesson;

  @override
  State<SlideshowLessonScreen> createState() => _SlideshowLessonScreenState();
}

class _SlideshowLessonScreenState extends State<SlideshowLessonScreen> {
  int _step = 0;
  bool _done = false;

  SlideshowLesson get lesson => widget.lesson;

  Color get color => AppPalette.of(lesson.color);

  int get total => lesson.steps.length;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakStep());
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }

  Future<void> _speakStep() async {
    final step = lesson.steps[_step];
    final text = step.speech ?? step.title;
    await TtsService.instance.speakSentence(text);
  }

  Future<void> _next() async {
    if (_step < total - 1) {
      TtsService.instance.stop();
      setState(() => _step++);
      _speakStep();
    } else {
      await ProgressService.instance.saveStars(lesson.id, 1);
      TtsService.instance.speakSentence('¡Has terminado la lección!');
      setState(() => _done = true);
    }
  }

  void _prev() {
    if (_step > 0) {
      TtsService.instance.stop();
      setState(() {
        _step--;
        _done = false;
      });
      _speakStep();
    }
  }

  void _openStepExercise(Exercise exercise) async {
    TtsService.instance.stop();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExerciseRunnerScreen(
          exercises: [exercise],
          colorName: lesson.color,
          unitId: lesson.id,
          title: lesson.title,
        ),
      ),
    );
    if (mounted && _step < total - 1) {
      setState(() => _step++);
      _speakStep();
    } else if (mounted) {
      await ProgressService.instance.saveStars(lesson.id, 1);
      setState(() => _done = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = lesson.steps[_step];

    final body = _done
        ? _doneView()
        : _stepView(step, _step == total - 1);

    final scaffold = Scaffold(
      backgroundColor: AppPalette.cream,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(lesson.title),
        backgroundColor: color.withOpacity(.15),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _progress(),
            Expanded(
              child: _done
                  ? Celebration(child: Center(child: body))
                  : Center(child: SingleChildScrollView(child: body)),
            ),
            if (!_done) _navBar(),
          ],
        ),
      ),
    );
    return scaffold;
  }

  Widget _progress() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (_step + 1) / total,
                minHeight: 10,
                backgroundColor: Colors.black.withOpacity(.08),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${_step + 1} / $total',
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
          if (_step > 0)
            Expanded(
              child: BigButton(
                label: 'Atrás',
                color: Colors.grey.shade500,
                icon: Icons.arrow_back_rounded,
                onPressed: _prev,
                fontSize: 18,
              ),
            ),
          if (_step > 0) const SizedBox(width: 12),
          Expanded(
            flex: _step == 0 ? 1 : 2,
            child: BigButton(
              label: _step == total - 1 ? 'Terminar' : 'Siguiente',
              color: color,
              icon: _step == total - 1
                  ? Icons.celebration_rounded
                  : Icons.arrow_forward_rounded,
              onPressed: _step == total - 1 ? _next : _next,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepView(StepItem step, bool isLast) {
    final hasExercise = step.exercise != null;
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: isLast ? color : AppPalette.ink,
              height: 1.15,
            ),
          ),
          if (step.subtitle != null) ...[
            const SizedBox(height: 10),
            Text(
              step.subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 19,
                color: Colors.black54,
                height: 1.25,
              ),
            ),
          ],
          if (step.bigText != null) ...[
            const SizedBox(height: 22),
            GestureDetector(
              onTap: step.showSpeaker
                  ? () => TtsService.instance.speakSlow(step.bigText!)
                  : null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 34, vertical: 18),
                decoration: BoxDecoration(
                  color: color.withOpacity(.12),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  step.bigText!,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 96,
                    fontWeight: FontWeight.w800,
                    color: color,
                    height: 1.15,
                  ),
                ),
              ),
            ),
          ],
          if (step.emoji != null) ...[
            const SizedBox(height: 22),
            Text(step.emoji!, style: const TextStyle(fontSize: 88)),
          ],
          if (hasExercise) ...[
            const SizedBox(height: 26),
            BigButton(
              label: '¡Intentar!',
              color: AppPalette.green,
              icon: Icons.sports_esports_rounded,
              onPressed: () => _openStepExercise(step.exercise!),
            ),
          ] else if (step.showSpeaker) ...[
            const SizedBox(height: 24),
            SpeakerButton(
              size: 64,
              color: color,
              onTap: _speakStep,
            ),
          ],
        ],
      ),
    );
  }

  Widget _doneView() {
    return Padding(
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
    );
  }
}
