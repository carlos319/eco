// Modelos de datos de la app EC0.
//
// Todo el contenido pedagógico (lecciones, palabras, ejercicios, frases y
// lecturas) se describe con estas clases y vive en `lib/data/`.

/// Una palabra con su división silábica y su imagen (asset o emoji).
class WordItem {
  const WordItem({
    required this.word,
    required this.syllables,
    this.emoji,
    this.image,
  });

  /// Palabra completa, por ejemplo `faro`.
  final String word;

  /// Sílabas, por ejemplo `['fa', 'ro']`.
  final List<String> syllables;

  /// Emoji de respaldo cuando no hay imagen propia.
  final String? emoji;

  /// Ruta del asset, por ejemplo `assets/images/faro.png`.
  final String? image;

  String get joined => syllables.join();
}

/// Tipos de ejercicio interactivo disponibles.
enum ExerciseType {
  /// Se muestra una imagen y el niño elige la palabra correcta (como el ppsx).
  pickWordForImage,

  /// El niño toca las sílabas en el orden correcto para formar la palabra.
  orderSyllables,

  /// Palabra con un hueco; el niño elige la sílaba que falta.
  completeWord,

  /// El niño selecciona todas las palabras que contienen la letra estudiada.
  findLetterWords,

  /// Pregunta visual con opciones emoji (para Iniciación y Vocales).
  chooseVisual,
}

/// Un ejercicio interactivo.
///
/// Los campos que se usan dependen de [type].
class Exercise {
  const Exercise({
    required this.type,
    required this.question,
    this.image,
    this.emoji,
    this.word,
    this.syllables = const [],
    this.options = const [],
    this.letter,
    this.missingIndex = 0,
    this.correctIndex = 0,
  });

  final ExerciseType type;

  /// Consigna que se lee en voz alta, p. ej. "¿Qué palabra es esta?".
  final String question;

  /// Imagen del ejercicio (para [ExerciseType.pickWordForImage]).
  final String? image;

  /// Emoji del ejercicio (para pickWordForImage / orderSyllables / chooseVisual).
  final String? emoji;

  /// Palabra correcta (para los tipos con palabra).
  final String? word;

  /// Sílabas de la palabra correcta.
  final List<String> syllables;

  /// Opciones: palabras (pickWordForImage), sílabas (completeWord),
  /// emojis (chooseVisual) o palabras simples (findLetterWords).
  final List<String> options;

  /// Letra objetivo para [ExerciseType.findLetterWords].
  final String? letter;

  /// Índice de la sílaba que falta ([ExerciseType.completeWord]).
  final int missingIndex;

  /// Índice de la opción correcta ([ExerciseType.chooseVisual]).
  final int correctIndex;

  String get answer => word ?? '';
}

/// Un paso de una lección tipo presentación (Iniciación y Vocales).
class StepItem {
  const StepItem({
    required this.title,
    this.subtitle,
    this.bigText,
    this.emoji,
    this.speech,
    this.exercise,
    this.showSpeaker = true,
  });

  final String title;
  final String? subtitle;

  /// Texto gigante central (letra, sílaba, palabra...).
  final String? bigText;

  final String? emoji;

  /// Texto que pronuncia el TTS al llegar al paso / pulsar el altavoz.
  final String? speech;

  /// Ejercicio opcional que se muestra en el paso.
  final Exercise? exercise;

  final bool showSpeaker;
}

/// Lección tipo presentación (Iniciación y Vocales).
class SlideshowLesson {
  const SlideshowLesson({
    required this.id,
    required this.title,
    required this.color,
    required this.steps,
  });

  final String id;
  final String title;

  /// Uno de los colores de [AppPalette].
  final String color;

  final List<StepItem> steps;
}

/// Lección de una consonante siguiendo el método (modelo del ppsx).
class LetterLesson {
  const LetterLesson({
    required this.id,
    required this.letter,
    required this.color,
    required this.syllables,
    required this.pictureWords,
    required this.words,
    required this.exercises,
    this.soundHint,
  });

  final String id;

  /// Letra minúscula, p. ej. `f`.
  final String letter;

  /// Color de la sección [AppPalette].
  final String color;

  /// Combinaciones con vocales: `['fa', 'fe', 'fi', 'fo', 'fu']`.
  final List<String> syllables;

  /// Palabras con imagen/emoji para "Con la f escribimos:".
  final List<WordItem> pictureWords;

  /// Palabras para la parte "¡Leamos!".
  final List<WordItem> words;

  final List<Exercise> exercises;

  /// Pista fonética, p. ej. `/fff/ como en el viento`.
  final String? soundHint;
}

/// Un paquete de palabras del nivel "Lee palabras 2" (palabras largas).
class WordPack {
  const WordPack({
    required this.id,
    required this.title,
    required this.color,
    required this.words,
    required this.exercises,
  });

  final String id;
  final String title;
  final String color;
  final List<WordItem> words;
  final List<Exercise> exercises;
}

/// Una frase para lectura con seguimiento palabra a palabra.
class PhraseItem {
  const PhraseItem({required this.words});

  /// Palabras de la frase.
  final List<String> words;

  String get text => words.join(' ');
}

/// Paquete de frases (nivel dentro de "Lee frases").
class PhrasePack {
  const PhrasePack({
    required this.id,
    required this.title,
    required this.color,
    required this.phrases,
  });

  final String id;
  final String title;
  final String color;
  final List<PhraseItem> phrases;
}

/// Una página de una lectura (cuento corto).
class ReadingPage {
  const ReadingPage({required this.lines});

  /// Líneas de texto de la página.
  final List<String> lines;

  String get text => lines.join(' ');
}

/// Una lectura completa con varias páginas.
class Reading {
  const Reading({
    required this.id,
    required this.title,
    required this.color,
    required this.emoji,
    required this.pages,
  });

  final String id;
  final String title;
  final String color;
  final String emoji;
  final List<ReadingPage> pages;
}

/// Secciones principales de la app.
enum SectionKind { initiation, vowels, words1, words2, phrases, readings }

/// Sección del menú principal.
class Ec0Section {
  const Ec0Section({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
  });

  final SectionKind kind;
  final String title;
  final String subtitle;
  final String emoji;
  final String color;
}
