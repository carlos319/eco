import '../models/models.dart';
import 'exercise_helpers.dart';

/// Sección 1 — Vocales: a, e, i, o, u.
final List<SlideshowLesson> vowelLessons = [
  SlideshowLesson(
    id: 'vocal_a',
    title: 'La vocal a',
    color: 'pink',
    steps: [
      StepItem(title: 'La vocal a', subtitle: 'Mayúscula y minúscula', bigText: 'A a', speech: 'Esta es la vocal a.'),
      StepItem(
        title: 'El sonido de la a',
        subtitle: 'Abre bien la boca: ¡aaaa!',
        bigText: 'a',
        speech: 'A',
      ),
      StepItem(
        title: 'Palabras con a',
        subtitle: 'Toca cada palabra para escucharla.',
        emoji: '✈️ 🌳 🐝',
        speech: 'Avión. Árbol. Abeja.',
      ),
      StepItem(
        title: '¿Cuál empieza con a?',
        subtitle: 'Toca la respuesta correcta.',
        showSpeaker: false,
        exercise: chooseVisual(
          question: '¿Cuál empieza con la vocal a?',
          options: ['🌳', '🐶', '🌞'],
          correctIndex: 0,
          speech: '¿Cuál empieza con la vocal a?',
        ),
      ),
    ],
  ),
  SlideshowLesson(
    id: 'vocal_e',
    title: 'La vocal e',
    color: 'teal',
    steps: [
      StepItem(title: 'La vocal e', subtitle: 'Mayúscula y minúscula', bigText: 'E e', speech: 'Esta es la vocal e.'),
      StepItem(
        title: 'El sonido de la e',
        subtitle: 'Con la boca sonriente: ¡eee!',
        bigText: 'e',
        speech: 'E',
      ),
      StepItem(
        title: 'Palabras con e',
        subtitle: 'Toca cada palabra para escucharla.',
        emoji: '🐘 ⭐ 🧹',
        speech: 'Elefante. Estrella. Escoba.',
      ),
      StepItem(
        title: '¿Cuál empieza con e?',
        subtitle: 'Toca la respuesta correcta.',
        showSpeaker: false,
        exercise: chooseVisual(
          question: '¿Cuál empieza con la vocal e?',
          options: ['🐘', '🚗', '🍎'],
          correctIndex: 0,
          speech: '¿Cuál empieza con la vocal e?',
        ),
      ),
    ],
  ),
  SlideshowLesson(
    id: 'vocal_i',
    title: 'La vocal i',
    color: 'indigo',
    steps: [
      StepItem(title: 'La vocal i', subtitle: 'Mayúscula y minúscula', bigText: 'I i', speech: 'Esta es la vocal i.'),
      StepItem(
        title: 'El sonido de la i',
        subtitle: 'Finita y aguda: ¡iii!',
        bigText: 'i',
        speech: 'I',
      ),
      StepItem(
        title: 'Palabras con i',
        subtitle: 'Toca cada palabra para escucharla.',
        emoji: '🏝️ 🐛 🛌',
        speech: 'Isla. Insecto. Iglú.',
      ),
      StepItem(
        title: '¿Cuál empieza con i?',
        subtitle: 'Toca la respuesta correcta.',
        showSpeaker: false,
        exercise: chooseVisual(
          question: '¿Cuál empieza con la vocal i?',
          options: ['🏝️', '🐴', '🍐'],
          correctIndex: 0,
          speech: '¿Cuál empieza con la vocal i?',
        ),
      ),
    ],
  ),
  SlideshowLesson(
    id: 'vocal_o',
    title: 'La vocal o',
    color: 'orange',
    steps: [
      StepItem(title: 'La vocal o', subtitle: 'Mayúscula y minúscula', bigText: 'O o', speech: 'Esta es la vocal o.'),
      StepItem(
        title: 'El sonido de la o',
        subtitle: 'Boca redondita: ¡ooo!',
        bigText: 'o',
        speech: 'O',
      ),
      StepItem(
        title: 'Palabras con o',
        subtitle: 'Toca cada palabra para escucharla.',
        emoji: '🐻 👁️ 🌊',
        speech: 'Oso. Ojo. Ola.',
      ),
      StepItem(
        title: '¿Cuál empieza con o?',
        subtitle: 'Toca la respuesta correcta.',
        showSpeaker: false,
        exercise: chooseVisual(
          question: '¿Cuál empieza con la vocal o?',
          options: ['🐻', '🖐️', '🚀'],
          correctIndex: 0,
          speech: '¿Cuál empieza con la vocal o?',
        ),
      ),
    ],
  ),
  SlideshowLesson(
    id: 'vocal_u',
    title: 'La vocal u',
    color: 'purple',
    steps: [
      StepItem(title: 'La vocal u', subtitle: 'Mayúscula y minúscula', bigText: 'U u', speech: 'Esta es la vocal u.'),
      StepItem(
        title: 'El sonido de la u',
        subtitle: 'Como cuando te sorprendes: ¡uuu!',
        bigText: 'u',
        speech: 'U',
      ),
      StepItem(
        title: 'Palabras con u',
        subtitle: 'Toca cada palabra para escucharla.',
        emoji: '🍇 🦄 1️⃣',
        speech: 'Uvas. Unicornio. Uno.',
      ),
      StepItem(
        title: '¿Cuál empieza con u?',
        subtitle: 'Toca la respuesta correcta.',
        showSpeaker: false,
        exercise: chooseVisual(
          question: '¿Cuál empieza con la vocal u?',
          options: ['🍇', '🗼', '🐢'],
          correctIndex: 0,
          speech: '¿Cuál empieza con la vocal u?',
        ),
      ),
    ],
  ),
];
