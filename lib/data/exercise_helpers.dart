import '../models/models.dart';

/// Helpers para definir ejercicios de forma compacta.
Exercise pickWord({
  required String question,
  String? image,
  String? emoji,
  required String word,
  required List<String> syllables,
  required List<String> options,
}) =>
    Exercise(
      type: ExerciseType.pickWordForImage,
      question: question,
      image: image,
      emoji: emoji,
      word: word,
      syllables: syllables,
      options: options,
    );

Exercise orderSyllables({
  required String word,
  required List<String> syllables,
  String? emoji,
  String? image,
}) =>
    Exercise(
      type: ExerciseType.orderSyllables,
      question: 'Toca las sílabas en orden para formar la palabra.',
      word: word,
      syllables: syllables,
      emoji: emoji,
      image: image,
      options: syllables,
    );

Exercise completeWord({
  required String word,
  required List<String> syllables,
  required int missingIndex,
  required List<String> options,
  String? emoji,
  String? image,
}) =>
    Exercise(
      type: ExerciseType.completeWord,
      question: '¿Qué sílaba falta?',
      word: word,
      syllables: syllables,
      missingIndex: missingIndex,
      options: options,
      emoji: emoji,
      image: image,
    );

Exercise findLetter({required String letter, required List<String> words}) =>
    Exercise(
      type: ExerciseType.findLetterWords,
      question: 'Toca las palabras que tienen la letra $letter.',
      letter: letter,
      options: words,
    );

Exercise chooseVisual({
  required String question,
  required List<String> options,
  required int correctIndex,
  String? speech,
}) =>
    Exercise(
      type: ExerciseType.chooseVisual,
      question: question,
      options: options,
      correctIndex: correctIndex,
    );
