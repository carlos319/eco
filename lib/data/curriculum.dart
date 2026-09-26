import '../models/activity.dart';
import '../models/models.dart';
import '../services/progress_service.dart';
import 'initiation_data.dart';
import 'letters_data.dart';
import 'phrases_data.dart' as phrases_data;
import 'readings_data.dart' as readings_data;
import 'vowels_data.dart';
import 'words2_data.dart' as words2_data;

/// Currículo completo de la app EC0.
class Curriculum {
  const Curriculum._();

  /// Secciones del menú principal (en orden pedagógico).
  static const List<Ec0Section> sections = [
    Ec0Section(
      kind: SectionKind.initiation,
      title: 'Iniciación',
      subtitle: 'Juega y prepárate para leer',
      emoji: '🌱',
      color: 'sky',
    ),
    Ec0Section(
      kind: SectionKind.vowels,
      title: 'Vocales',
      subtitle: 'A · E · I · O · U',
      emoji: '🅰️',
      color: 'pink',
    ),
    Ec0Section(
      kind: SectionKind.words1,
      title: 'Lee palabras',
      subtitle: 'Lecciones por letra',
      emoji: '📖',
      color: 'green',
    ),
    Ec0Section(
      kind: SectionKind.words2,
      title: 'Lee palabras 2',
      subtitle: 'Palabras más largas',
      emoji: '🚀',
      color: 'orange',
    ),
    Ec0Section(
      kind: SectionKind.phrases,
      title: 'Lee frases',
      subtitle: 'Frases paso a paso',
      emoji: '✏️',
      color: 'purple',
    ),
    Ec0Section(
      kind: SectionKind.readings,
      title: 'Lecturas',
      subtitle: 'Cuentos completos',
      emoji: '📚',
      color: 'yellow',
    ),
  ];

  static List<SlideshowLesson> initiation() => initiationLessons;
  static List<SlideshowLesson> vowels() => vowelLessons;
  static List<LetterLesson> letters() => letterLessons;
  static List<WordPack> wordPacks() => words2_data.wordPacks;
  static List<PhrasePack> phrasePacks() => phrases_data.phrasePacks;
  static List<Reading> readings() => readings_data.readings;

  /// Ids de unidades de cada sección (para progreso y desbloqueo).
  static Map<String, List<String>> unitIdsBySection() => {
        // Iniciación: las 15 actividades del módulo nuevo (a01–a15),
        // tomadas del catálogo para que siempre estén sincronizadas.
        'iniciacion': ActivityCatalog.all.map((a) => a.id).toList(),
        'vocales': vowelLessons.map((l) => l.id).toList(),
        'palabras1': letterLessons.map((l) => l.id).toList(),
        'palabras2': words2_data.wordPacks.map((l) => l.id).toList(),
        'frases': phrases_data.phrasePacks.map((l) => l.id).toList(),
        'lecturas': readings_data.readings.map((l) => l.id).toList(),
      };

  /// Registra el orden de unidades en el servicio de progreso.
  static void registerWith(ProgressService progress) {
    unitIdsBySection().forEach(progress.registerSection);
  }
}