import '../models/models.dart';
import 'exercise_helpers.dart';

/// Sección 0 — Iniciación: preparación para la lectura.
///
/// Trazos, dirección de la lectura y primeros conceptos visuales.
final List<SlideshowLesson> initiationLessons = [
  // ------------------------------------------------ 1. Trazos y líneas
  SlideshowLesson(
    id: 'ini_trazos',
    title: 'Trazos y líneas',
    color: 'sky',
    steps: [
      StepItem(
        title: '¡Hola, lector!',
        subtitle:
            'Antes de leer vamos a entrenar los ojos y las manos.\nToca el altavoz para escuchar.',
        emoji: '🌟',
        speech: '¡Hola! Antes de leer, vamos a entrenar los ojos y las manos.',
      ),
      StepItem(
        title: 'La línea vertical',
        subtitle: 'De arriba hacia abajo, como la lluvia.',
        bigText: '❘',
        speech: 'La línea vertical va de arriba hacia abajo, como la lluvia.',
      ),
      StepItem(
        title: 'La línea horizontal',
        subtitle: 'De izquierda a derecha, así leemos.',
        bigText: '▬',
        speech: 'La línea horizontal va de izquierda a derecha.',
      ),
      StepItem(
        title: 'El círculo',
        subtitle: 'Redondito, como una rueda.',
        bigText: '◯',
        speech: 'El círculo es redondito como una rueda.',
      ),
      StepItem(
        title: 'El zigzag',
        subtitle: 'Arriba, abajo, arriba, abajo… como los rayos.',
        bigText: '⚡',
        speech: 'El zigzag sube y baja como los rayos.',
      ),
      StepItem(
        title: '¿Cuál es la línea recta?',
        subtitle: 'Toca la respuesta correcta.',
        showSpeaker: false,
        exercise: chooseVisual(
          question: 'Toca la línea horizontal:',
          options: ['❘', '▬', '◯'],
          correctIndex: 1,
          speech: 'Toca la línea horizontal.',
        ),
      ),
      StepItem(
        title: '¿Cuál es el círculo?',
        subtitle: 'Toca la respuesta correcta.',
        showSpeaker: false,
        exercise: chooseVisual(
          question: 'Toca el círculo:',
          options: ['⚡', '◯', '❘'],
          correctIndex: 1,
          speech: 'Toca el círculo.',
        ),
      ),
    ],
  ),

  // ------------------------------------------------ 2. Izquierda a derecha
  SlideshowLesson(
    id: 'ini_direccion',
    title: 'De izquierda a derecha',
    color: 'green',
    steps: [
      StepItem(
        title: '¿De dónde empezamos?',
        subtitle: 'Las palabras empiezan aquí 👈 y terminan ahí 👉.\nLeemos así: punto de salida… ¡y punto de llegada!',
        emoji: '👉',
        speech: 'Las palabras empiezan en este lado y terminan en el otro. Leemos de izquierda a derecha.',
      ),
      StepItem(
        title: 'Mira la flecha',
        subtitle: 'La flecha siempre apunta hacia dónde vamos a leer.',
        bigText: '👉',
        speech: 'La flecha apunta hacia donde vamos a leer: de izquierda a derecha.',
      ),
      StepItem(
        title: 'Practiquemos con pelotas',
        subtitle: 'Primero la pelota verde, después la roja.',
        emoji: '🟢🔴',
        speech: 'Primero la pelota verde, después la pelota roja.',
      ),
      StepItem(
        title: '¿Cuál va primero?',
        subtitle: 'Toca la pelota que está a la izquierda.',
        showSpeaker: false,
        exercise: chooseVisual(
          question: 'Toca la pelota que está a la izquierda:',
          options: ['🔴', '🟢'],
          correctIndex: 0,
          speech: 'Toca la pelota que está a la izquierda.',
        ),
      ),
      StepItem(
        title: '¿Y ahora?',
        subtitle: 'Toca la estrella que está a la derecha.',
        showSpeaker: false,
        exercise: chooseVisual(
          question: 'Toca la estrella que está a la derecha:',
          options: ['⭐', '🌟'],
          correctIndex: 1,
          speech: 'Toca la estrella que está a la derecha.',
        ),
      ),
    ],
  ),

  // ------------------------------------------------ 3. Grande y pequeño
  SlideshowLesson(
    id: 'ini_conceptos',
    title: 'Grande, pequeño, igual y diferente',
    color: 'orange',
    steps: [
      StepItem(
        title: 'Grande y pequeño',
        subtitle: 'Mira al elefante grande y a la hormiga pequeña.',
        emoji: '🐘🐜',
        speech: 'El elefante es grande. La hormiga es pequeña.',
      ),
      StepItem(
        title: '¿Cuál es grande?',
        subtitle: 'Toca el animal grande.',
        showSpeaker: false,
        exercise: chooseVisual(
          question: 'Toca el animal grande:',
          options: ['🐜', '🐘'],
          correctIndex: 1,
          speech: 'Toca el animal grande.',
        ),
      ),
      StepItem(
        title: 'Iguales',
        subtitle: 'Estos dos son iguales: 🍎🍎',
        emoji: '🍎🍎',
        speech: 'Estas dos manzanas son iguales.',
      ),
      StepItem(
        title: 'Diferentes',
        subtitle: 'Este par es diferente: 🍎🍐',
        emoji: '🍎🍐',
        speech: 'La manzana y la pera son diferentes.',
      ),
      StepItem(
        title: '¿Cuál par es diferente?',
        subtitle: 'Toca el par diferente.',
        showSpeaker: false,
        exercise: chooseVisual(
          question: 'Toca el par de frutas diferentes:',
          options: ['🍌🍌', '🍓🍌', '🍇🍇'],
          correctIndex: 1,
          speech: 'Toca el par de frutas diferentes.',
        ),
      ),
    ],
  ),
];
