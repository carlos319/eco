import '../models/models.dart';

/// Sección 3 — Lee frases: paquetes de frases simples con vocabulario
/// controlado del método (sílabas directas ya aprendidas).
final List<PhrasePack> phrasePacks = [
  PhrasePack(
    id: 'frases_1',
    title: 'Nivel 1 · m, p, l',
    color: 'pink',
    phrases: const [
      PhraseItem(words: ['Mi', 'mamá', 'me', 'mima.']),
      PhraseItem(words: ['El', 'papá', 'pinta', 'un', 'mapa.']),
      PhraseItem(words: ['La', 'mesa', 'de', 'la', 'sala.']),
      PhraseItem(words: ['El', 'mono', 'come', 'una', 'manzana.']),
    ],
  ),
  PhrasePack(
    id: 'frases_2',
    title: 'Nivel 2 · l, s, n',
    color: 'teal',
    phrases: const [
      PhraseItem(words: ['El', 'sol', 'y', 'la', 'luna.']),
      PhraseItem(words: ['El', 'loro', 'come', 'limón.']),
      PhraseItem(words: ['El', 'sapo', 'nada', 'y', 'nada.']),
      PhraseItem(words: ['La', 'nube', 'pasa', 'al', 'nido.']),
    ],
  ),
  PhrasePack(
    id: 'frases_3',
    title: 'Nivel 3 · d, t, f',
    color: 'sky',
    phrases: const [
      PhraseItem(words: ['El', 'dado', 'de', 'Ana', 'es', 'rojo.']),
      PhraseItem(words: ['La', 'taza', 'de', 'té.']),
      PhraseItem(words: ['La', 'foto', 'de', 'mamá.']),
      PhraseItem(words: ['El', 'foco', 'del', 'faro', 'da', 'luz.']),
    ],
  ),
  PhrasePack(
    id: 'frases_4',
    title: 'Nivel 4 · b, v, r',
    color: 'green',
    phrases: const [
      PhraseItem(words: ['La', 'vaca', 'bebe', 'agua.']),
      PhraseItem(words: ['Mi', 'bota', 'y', 'tu', 'bota.']),
      PhraseItem(words: ['El', 'regalo', 'de', 'Rosa.']),
      PhraseItem(words: ['El', 'barco', 'de', 'vapor', 'va', 'y', 'va.']),
    ],
  ),
  PhrasePack(
    id: 'frases_5',
    title: 'Nivel 5 · g, c, j',
    color: 'orange',
    phrases: const [
      PhraseItem(words: ['El', 'gato', 'se', 'esconde.']),
      PhraseItem(words: ['La', 'cama', 'del', 'gato.']),
      PhraseItem(words: ['El', 'conejo', 'come', 'y', 'come.']),
      PhraseItem(words: ['El', 'ajo', 'y', 'el', 'jabón.']),
    ],
  ),
  PhrasePack(
    id: 'frases_6',
    title: 'Nivel 6 · Repaso',
    color: 'purple',
    phrases: const [
      PhraseItem(words: ['La', 'jirafa', 'alta', 'come', 'hojas.']),
      PhraseItem(words: ['La', 'muñeca', 'duerme', 'en', 'la', 'cama.']),
      PhraseItem(words: ['La', 'araña', 'teje', 'y', 'teje.']),
      PhraseItem(words: ['Mi', 'familia', 'lee', 'junto', 'al', 'faro.']),
    ],
  ),
];
