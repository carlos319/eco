# EC0 · Aprende a leer 🦉

App de lectoescritura en **Flutter** con el método silábico, construida a partir
de las presentaciones originales (f.ppsx) y la estructura de carpetas:
**Iniciación → Vocales → Palabras → Frases → Lecturas**.

---

## 📱 Qué incluye la app

| Sección | Contenido |
|---|---|
| 🌱 **Iniciación** | 3 lecciones: trazos y líneas, dirección de lectura (izquierda→derecha) y conceptos (grande/pequeño, igual/diferente) |
| 🅰️ **Vocales** | 5 lecciones (a, e, i, o, u): letra, sonido, palabras y ejercicio |
| 📖 **Lee palabras** | 15 lecciones por letra (m, p, l, s, n, d, t, **f**, b, v, r, g, c, j, ñ) siguiendo el flujo exacto del ppsx: portada → letra → "Con la f escribimos" → sonido → combinación con vocales → "¡Leamos!" → palabras sílaba a sílaba → **Ejercicio "Evalúo mis logros"** → fin |
| 🚀 **Lee palabras 2** | 4 paquetes de palabras largas (animales, casa, comida, calle) con lectura silábica y ejercicios |
| ✏️ **Lee frases** | 6 niveles de frases con lectura palabra a palabra (karaoke) |
| 📚 **Lecturas** | 4 cuentos paginados con lectura acompañada |

**Ejercicios interactivos** (con feedback *¡MUY BIEN!* / *No es esa*, como el
ppsx): palabra+imagen, ordenar sílabas, completar sílaba, identificar la letra
y preguntas visuales.

**Extras**: voz en español (TTS del sistema, sin archivos de audio), estrellas
por lección (1-3⭐), desbloqueo progresivo de secciones, zona de padres para
desbloquear todo, confeti de celebración y las imágenes reales del ppsx
(faro, foca, fila, foco, café, teléfono, foto, feo, casa).

---

## ✅ Requisitos para compilar

1. **Flutter SDK** (3.22 o superior) — https://docs.flutter.dev/get-started/install
2. **Android Studio** (para el SDK de Android) o solo la línea de comandos de
   Android, con un emulador o dispositivo conectado.
3. Verifica el entorno: `flutter doctor`

> El proyecto incluye ya las carpetas `android/` y todo lo necesario:
> `lib/`, `test/`, `pubspec.yaml`, `assets/` y `android/`. Está verificado
> con `flutter analyze` (0 problemas) y con tests automatizados que pasan.

---

## 🚀 Compilar y ejecutar (paso a paso)

```bash
# 1. Descomprime el ZIP y entra a la carpeta
cd ec0_app

# 2. Descarga las dependencias
flutter pub get

# 3. Conecta un teléfono Android (con Depuración USB activada)
#    o abre un emulador, y ejecuta:
flutter run
```

### Generar el APK para instalar/compartir

```bash
# APK de prueba (instala directo en cualquier Android)
flutter build apk --release

# El archivo queda en:
# build/app/outputs/flutter-apk/app-release.apk
```

Para generar un **APK universal** (compatible con todos los dispositivos):

```bash
flutter build apk --release --target-platform android-arm64
```

---

## 🔊 Notas sobre la voz (TTS)

- La app usa la voz en español del **sistema Android** (Google TTS).
- Si no se oye nada: *Ajustes → Administración de idiomas y entrada →
  Síntesis de voz → Google → instalar datos de voz en Español*.
- No requiere descargar ningún archivo de audio dentro de la app.
- Velocidad lenta configurada especialmente para niños en aprendizaje
  (`lib/services/tts_service.dart`).

---

## 🖼️ Cómo cambiar las imágenes

Las imágenes del ppsx están en `assets/images/`. Para reemplazar una,
guarda tu foto con el mismo nombre (por ejemplo `faro.png`). Para agregar
imágenes nuevas a otras palabras:

1. Copia tu imagen a `assets/images/` (ej. `mesa.png`).
2. En `lib/data/letters_data.dart`, cambia el `emoji` por `image`:

```dart
// Antes (emoji):
WordItem(word: 'mesa', syllables: ['me', 'sa'], emoji: '🪑'),
// Después (tu imagen):
WordItem(word: 'mesa', syllables: ['me', 'sa'], image: 'assets/images/mesa.png'),
```

---

## 📂 Estructura del código

```
ec0_app/
├── assets/
│   ├── images/          ← imágenes reales extraídas del ppsx
│   └── fonts/           ← fuente infantil Baloo 2
├── lib/
│   ├── main.dart        ← arranque de la app
│   ├── core/
│   │   └── app_theme.dart      ← colores y tema infantil
│   ├── models/
│   │   └── models.dart         ← lecciones, palabras, ejercicios…
│   ├── data/                   ← TODO EL CONTENIDO PEDAGÓGICO
│   │   ├── curriculum.dart     ← secciones y orden
│   │   ├── initiation_data.dart
│   │   ├── vowels_data.dart
│   │   ├── letters_data.dart   ← las 15 letras (la f replica el ppsx)
│   │   ├── words2_data.dart
│   │   ├── phrases_data.dart
│   │   ├── readings_data.dart
│   │   └── exercise_helpers.dart
│   ├── services/
│   │   ├── tts_service.dart    ← voz en español
│   │   └── progress_service.dart ← estrellas y desbloqueos
│   ├── screens/
│   │   ├── home_screen.dart            ← menú principal
│   │   ├── lesson_list_screen.dart     ← lecciones de cada sección
│   │   ├── letter_lesson_screen.dart   ← lección estilo ppsx (9 pasos)
│   │   ├── slideshow_lesson_screen.dart← iniciación y vocales
│   │   ├── exercise_runner.dart        ← "Evalúo mis logros"
│   │   ├── word_pack_screen.dart       ← lee palabras 2
│   │   ├── phrase_screen.dart          ← frases karaoke
│   │   └── reading_screen.dart         ← cuentos
│   └── widgets/
│       ├── buttons.dart        ← botones 3D infantiles
│       ├── common.dart         ← sílabas, imágenes, estrellas
│       └── feedback.dart       ← ¡MUY BIEN! / No es esa + confeti
└── pubspec.yaml
```

---

## 🎓 Cómo agregar una letra nueva (ejemplo)

Edita `lib/data/letters_data.dart` y agrega dentro de `letterLessons`:

```dart
LetterLesson(
  id: 'letra_z',
  letter: 'z',
  color: 'teal',
  syllables: ['za', 'ze', 'zi', 'zo', 'zu'],
  pictureWords: [
    WordItem(word: 'zorro', syllables: ['zo', 'rro'], emoji: '🦊'),
    // ... más palabras
  ],
  words: [
    WordItem(word: 'zorro', syllables: ['zo', 'rro'], emoji: '🦊'),
  ],
  exercises: [
    pickWord(
      question: 'Mira la imagen y elige la palabra.',
      emoji: '🦊',
      word: 'zorro',
      syllables: ['zo', 'rro'],
      options: ['zorro', 'torre', 'zapato'],
    ),
    orderSyllables(word: 'zorro', syllables: ['zo', 'rro'], emoji: '🦊'),
    completeWord(
      word: 'zapato',
      syllables: ['za', 'pa', 'to'],
      missingIndex: 0,
      options: ['za', 'ce', 'ci'],
      emoji: '👟',
    ),
    findLetter(letter: 'z', words: ['zorro', 'casa', 'taza', 'mesa']),
  ],
),
```

La app detecta la lección nueva automáticamente (lista, candados y estrellas).
