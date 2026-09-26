import '../models/models.dart';

/// Sección 4 — Lecturas: cuentos cortos paginados con vocabulario
/// controlado del método silábico.
final List<Reading> readings = [
  Reading(
    id: 'lectura_mono',
    title: 'El mono Momo',
    color: 'orange',
    emoji: '🐵',
    pages: const [
      ReadingPage(lines: [
        'Momo es un mono.',
        'Vive en la selva',
        'con su mamá.',
      ]),
      ReadingPage(lines: [
        'La mamá de Momo lo mima.',
        'Le da una manzana',
        'y media banana.',
      ]),
      ReadingPage(lines: [
        'Momo come y come.',
        'Luego duerme en su cama.',
        'Fin.',
      ]),
    ],
  ),
  Reading(
    id: 'lectura_foca',
    title: 'La foca Lila',
    color: 'sky',
    emoji: '🦭',
    pages: const [
      ReadingPage(lines: [
        'Lila es una foca.',
        'Lila ama el agua',
        'y juega en la playa.',
      ]),
      ReadingPage(lines: [
        'Un día, Lila ve un faro.',
        'El foco del faro',
        'da muchas luces.',
      ]),
      ReadingPage(lines: [
        'Lila hace fila',
        'con las focas',
        'para ver el faro.',
        'Fin.',
      ]),
    ],
  ),
  Reading(
    id: 'lectura_sapo',
    title: 'El sapo Tomás',
    color: 'green',
    emoji: '🐸',
    pages: const [
      ReadingPage(lines: [
        'Tomás es un sapo.',
        'Toma el sol',
        'sobre una seta.',
      ]),
      ReadingPage(lines: [
        'Salta a la izquierda,',
        'salta a la derecha.',
        'Salta y salta.',
      ]),
      ReadingPage(lines: [
        'Al final, Tomás toma',
        'una sopa de nata.',
        '¡Qué bien!',
        'Fin.',
      ]),
    ],
  ),
  Reading(
    id: 'lectura_familia',
    title: 'Mi familia',
    color: 'pink',
    emoji: '👨‍👩‍👧',
    pages: const [
      ReadingPage(lines: [
        'Mi papá es alto.',
        'Toma café en la mañana',
        'y lee el mapa del barrio.',
      ]),
      ReadingPage(lines: [
        'Mi mamá pinta cuadros.',
        'Pinta la luna, el sol',
        'y una familia.',
      ]),
      ReadingPage(lines: [
        'Yo tomo la foto',
        'con mi teléfono.',
        '¡Somos una familia feliz!',
        'Fin.',
      ]),
    ],
  ),
];
