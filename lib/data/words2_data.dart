import '../models/models.dart';
import 'exercise_helpers.dart';

/// Sección "Lee palabras 2": paquetes de palabras largas (3-4 sílabas).
final List<WordPack> wordPacks = [
  WordPack(
    id: 'pack_animales',
    title: 'Animales',
    color: 'green',
    words: const [
      WordItem(word: 'tortuga', syllables: ['tor', 'tu', 'ga'], emoji: '🐢'),
      WordItem(word: 'jirafa', syllables: ['ji', 'ra', 'fa'], emoji: '🦒'),
      WordItem(word: 'elefante', syllables: ['e', 'le', 'fan', 'te'], emoji: '🐘'),
      WordItem(word: 'mariposa', syllables: ['ma', 'ri', 'po', 'sa'], emoji: '🦋'),
      WordItem(word: 'conejo', syllables: ['co', 'ne', 'jo'], emoji: '🐰'),
      WordItem(word: 'murciélago', syllables: ['mur', 'cié', 'la', 'go'], emoji: '🦇'),
    ],
    exercises: [
      orderSyllables(
        word: 'mariposa',
        syllables: ['ma', 'ri', 'po', 'sa'],
        emoji: '🦋',
      ),
      completeWord(
        word: 'elefante',
        syllables: ['e', 'le', 'fan', 'te'],
        missingIndex: 2,
        options: ['fan', 'fon', 'fen'],
        emoji: '🐘',
      ),
      orderSyllables(
        word: 'tortuga',
        syllables: ['tor', 'tu', 'ga'],
        emoji: '🐢',
      ),
    ],
  ),
  WordPack(
    id: 'pack_casa',
    title: 'En casa',
    color: 'orange',
    words: const [
      WordItem(word: 'camisa', syllables: ['ca', 'mi', 'sa'], emoji: '👕'),
      WordItem(word: 'ventana', syllables: ['ven', 'ta', 'na'], emoji: '🪟'),
      WordItem(word: 'escoba', syllables: ['es', 'co', 'ba'], emoji: '🧹'),
      WordItem(word: 'bombilla', syllables: ['bom', 'bi', 'lla'], emoji: '💡'),
      WordItem(word: 'calcetín', syllables: ['cal', 'ce', 'tín'], emoji: '🧦'),
      WordItem(word: 'cuaderno', syllables: ['cua', 'der', 'no'], emoji: '📓'),
    ],
    exercises: [
      orderSyllables(
        word: 'ventana',
        syllables: ['ven', 'ta', 'na'],
        emoji: '🪟',
      ),
      completeWord(
        word: 'escoba',
        syllables: ['es', 'co', 'ba'],
        missingIndex: 1,
        options: ['co', 'ca', 'cu'],
        emoji: '🧹',
      ),
      orderSyllables(
        word: 'cuaderno',
        syllables: ['cua', 'der', 'no'],
        emoji: '📓',
      ),
    ],
  ),
  WordPack(
    id: 'pack_comida',
    title: 'Comida',
    color: 'red',
    words: const [
      WordItem(word: 'helado', syllables: ['he', 'la', 'do'], emoji: '🍦'),
      WordItem(word: 'sandía', syllables: ['san', 'dí', 'a'], emoji: '🍉'),
      WordItem(word: 'cebolla', syllables: ['ce', 'bo', 'lla'], emoji: '🧅'),
      WordItem(word: 'tomate', syllables: ['to', 'ma', 'te'], emoji: '🍅'),
      WordItem(word: 'banana', syllables: ['ba', 'na', 'na'], emoji: '🍌'),
      WordItem(word: 'chocolate', syllables: ['cho', 'co', 'la', 'te'], emoji: '🍫'),
    ],
    exercises: [
      orderSyllables(
        word: 'helado',
        syllables: ['he', 'la', 'do'],
        emoji: '🍦',
      ),
      completeWord(
        word: 'chocolate',
        syllables: ['cho', 'co', 'la', 'te'],
        missingIndex: 0,
        options: ['cho', 'cha', 'co'],
        emoji: '🍫',
      ),
      orderSyllables(
        word: 'tomate',
        syllables: ['to', 'ma', 'te'],
        emoji: '🍅',
      ),
    ],
  ),
  WordPack(
    id: 'pack_calle',
    title: 'A la calle',
    color: 'sky',
    words: const [
      WordItem(word: 'bicicleta', syllables: ['bi', 'ci', 'cle', 'ta'], emoji: '🚲'),
      WordItem(word: 'cohete', syllables: ['co', 'he', 'te'], emoji: '🚀'),
      WordItem(word: 'teléfono',
          syllables: ['te', 'lé', 'fo', 'no'],
          image: 'assets/images/telefono.png'),
      WordItem(word: 'planeta', syllables: ['pla', 'ne', 'ta'], emoji: '🪐'),
      WordItem(word: 'trompeta', syllables: ['trom', 'pe', 'ta'], emoji: '🎺'),
      WordItem(word: 'globo', syllables: ['glo', 'bo'], emoji: '🎈'),
    ],
    exercises: [
      orderSyllables(
        word: 'bicicleta',
        syllables: ['bi', 'ci', 'cle', 'ta'],
        emoji: '🚲',
      ),
      completeWord(
        word: 'planeta',
        syllables: ['pla', 'ne', 'ta'],
        missingIndex: 2,
        options: ['ta', 'te', 'ti'],
        emoji: '🪐',
      ),
      orderSyllables(
        word: 'cohete',
        syllables: ['co', 'he', 'te'],
        emoji: '🚀',
      ),
    ],
  ),
];
