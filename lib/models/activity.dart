// Modelos del módulo de Iniciación (aprestamiento / prelectura).
// Todo va en voz: el niño aún NO lee.

/// Niveles del mapa de Iniciación, en orden de desbloqueo.
enum ActivityLevel {
  visual('Percepción visual', '👀', 'sky'),
  auditiva('Percepción auditiva', '👂', 'green'),
  motricidad('Motricidad y trazo', '✋', 'yellow'),
  lenguaje('Lenguaje y comprensión', '💬', 'orange');

  const ActivityLevel(this.name, this.emoji, this.color);

  final String name;
  final String emoji;
  final String color;
}

/// Una actividad de aprestamiento.
class ActivitySpec {
  const ActivitySpec({
    required this.id,
    required this.code,
    required this.name,
    required this.emoji,
    required this.level,
    required this.instruction,
  });

  /// Identificador único para progreso, p. ej. `a01`.
  final String id;

  /// Etiqueta visible para adultos, p. ej. `A01`.
  final String code;

  /// Nombre corto hablado y mostrado.
  final String name;
  final String emoji;
  final ActivityLevel level;

  /// Instrucción inicial que lee la lechuza al entrar.
  final String instruction;
}

/// Registro de las 15 actividades de Iniciación, en orden de juego.
class ActivityCatalog {
  const ActivityCatalog._();

  static const List<ActivitySpec> all = [
    // ─────────── NIVEL 1 · PERCEPCIÓN VISUAL ───────────
    ActivitySpec(
      id: 'a01',
      code: 'A01',
      name: 'Igual o diferente',
      emoji: '🔍',
      level: ActivityLevel.visual,
      instruction: '¡Hola! En cada fila hay un intruso. Toca el que es diferente.',
    ),
    ActivitySpec(
      id: 'a02',
      code: 'A02',
      name: '¿Qué le falta?',
      emoji: '🧩',
      level: ActivityLevel.visual,
      instruction: 'A estos dibujos les falta una parte. Arrastra la parte que falta.',
    ),
    ActivitySpec(
      id: 'a03',
      code: 'A03',
      name: 'De izquierda a derecha',
      emoji: '➡️',
      level: ActivityLevel.visual,
      instruction: 'La oruga tiene hambre. Desliza hacia la derecha para que coma las hojas. ¡Siempre hacia este lado!',
    ),
    // ─────────── NIVEL 2 · PERCEPCIÓN AUDITIVA ───────────
    ActivitySpec(
      id: 'a04',
      code: 'A04',
      name: '¡Aplasta el sonido!',
      emoji: '🎵',
      level: ActivityLevel.auditiva,
      instruction: 'Escucha el sonido y aplasta solo los dibujos que empiezan igual.',
    ),
    ActivitySpec(
      id: 'a05',
      code: 'A05',
      name: '¿Cuántos golpes?',
      emoji: '🥁',
      level: ActivityLevel.auditiva,
      instruction: 'Vamos a tocar la palabra con el tambor. Escucha y golpea al ritmo.',
    ),
    ActivitySpec(
      id: 'a06',
      code: 'A06',
      name: 'Rima, rima',
      emoji: '🎶',
      level: ActivityLevel.auditiva,
      instruction: '¿Riman las dos palabras? Si riman, arrástralas al imán. Si no riman, a la canasta.',
    ),
    ActivitySpec(
      id: 'a07',
      code: 'A07',
      name: 'Sonido inicial y final',
      emoji: '🔑',
      level: ActivityLevel.auditiva,
      instruction: '¿Con qué sonido empieza la palabra? Escucha bien y toca la letra.',
    ),
    // ─────────── NIVEL 3 · MOTRICIDAD Y TRAZO ───────────
    ActivitySpec(
      id: 'a08',
      code: 'A08',
      name: 'Traza con el dedo',
      emoji: '✏️',
      level: ActivityLevel.motricidad,
      instruction: 'Traza la letra con tu dedo, despacito, siguiendo los puntitos.',
    ),
    ActivitySpec(
      id: 'a09',
      code: 'A09',
      name: 'Dibuja en el aire',
      emoji: '🌬️',
      level: ActivityLevel.motricidad,
      instruction: 'Vamos a dibujar con el dedo en el aire, bien grandote. Cuando termines, toca el botón.',
    ),
    ActivitySpec(
      id: 'a10',
      code: 'A10',
      name: 'Pinza mágica',
      emoji: '🫰',
      level: ActivityLevel.motricidad,
      instruction: 'Guarda las bolitas en el frasco, una por una, con tus deditos.',
    ),
    // ─────────── NIVEL 4 · LENGUAJE Y COMPRENSIÓN ───────────
    ActivitySpec(
      id: 'a11',
      code: 'A11',
      name: '¿Qué sigue?',
      emoji: '🔄',
      level: ActivityLevel.lenguaje,
      instruction: 'Mira la historia y elige qué va al final. Toca el dibujo correcto.',
    ),
    ActivitySpec(
      id: 'a12',
      code: 'A12',
      name: 'Ordena mi historia',
      emoji: '📚',
      level: ActivityLevel.lenguaje,
      instruction: 'La historia se desordenó. Toca los dibujos en orden: primero, después, al final.',
    ),
    ActivitySpec(
      id: 'a13',
      code: 'A13',
      name: 'Adivina adivinador',
      emoji: '🤔',
      level: ActivityLevel.lenguaje,
      instruction: 'Escucha la adivinanza y toca la respuesta.',
    ),
    ActivitySpec(
      id: 'a14',
      code: 'A14',
      name: '¿Dónde está el intruso?',
      emoji: '🕵️',
      level: ActivityLevel.lenguaje,
      instruction: 'Cuatro dibujos y uno miente. Toca el que NO va con los demás.',
    ),
    ActivitySpec(
      id: 'a15',
      code: 'A15',
      name: 'Mi primer libro parlante',
      emoji: '📖',
      level: ActivityLevel.lenguaje,
      instruction: '¡Vas a leer tu primera frase! Arrastra las palabras a su lugar y escucha la magia.',
    ),
  ];

  /// Actividades de un nivel, en orden.
  static List<ActivitySpec> byLevel(ActivityLevel level) =>
      all.where((a) => a.level == level).toList();

  /// Índice global de una actividad por id (para desbloqueo secuencial).
  static int indexOf(String id) => all.indexWhere((a) => a.id == id);

  /// Busca una actividad por id.
  static ActivitySpec? byId(String id) {
    for (final a in all) {
      if (a.id == id) return a;
    }
    return null;
  }

  /// Niveles en orden.
  static const List<ActivityLevel> levels = ActivityLevel.values;
}