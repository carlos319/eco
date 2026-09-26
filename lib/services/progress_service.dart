import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/activity.dart';

/// Progreso del niño: estrellas por lección y desbloqueo progresivo.
///
/// Reglas:
/// - Cada unidad (lección/paquete) guarda 0-3 estrellas.
/// - Cada actividad de Iniciación guarda 0-5 estrellas (una por ronda).
/// - Una unidad se desbloquea si es la primera de su sección o si la
///   anterior ya tiene al menos 1 estrella.
/// - Una sección se desbloquea si la sección anterior está completa
///   (todas sus unidades con al menos 1 estrella) o con el botón de padres.
class ProgressService extends ChangeNotifier {
  ProgressService._();

  static final ProgressService instance = ProgressService._();

  static const _starsPrefix = 'stars:';
  static const _activityStarsPrefix = 'astars:';
  static const _unlockAllKey = 'unlock_all';

  SharedPreferences? _prefs;

  /// Identificadores de unidades por sección, en orden.
  /// Los datos reales se registran desde [Curriculum] al arrancar.
  final Map<String, List<String>> _unitsBySection = {};

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Registra el orden de unidades de una sección (id de sección -> ids).
  void registerSection(String sectionId, List<String> unitIds) {
    _unitsBySection[sectionId] = unitIds;
  }

  // ---------------------------------------------------------------- estrellas

  int starsFor(String unitId) =>
      _prefs?.getInt('$_starsPrefix$unitId') ?? 0;

  /// Estrellas de una actividad de Iniciación (0-5, una por ronda).
  int activityStarsFor(String activityId) =>
      _prefs?.getInt('$_activityStarsPrefix$activityId') ?? 0;

  /// Guarda el máximo entre las estrellas actuales y [stars].
  Future<void> saveStars(String unitId, int stars) async {
    final prefs = _prefs;
    if (prefs == null) return;
    final current = starsFor(unitId);
    if (stars > current) {
      await prefs.setInt('$_starsPrefix$unitId', stars.clamp(0, 3));
      notifyListeners();
    } else {
      notifyListeners();
    }
  }

  /// Guarda el máximo de estrellas de una actividad (0-5, histórico).
  Future<void> saveActivityStars(String activityId, int stars) async {
    final prefs = _prefs;
    if (prefs == null) return;
    final current = activityStarsFor(activityId);
    if (stars > current) {
      await prefs.setInt(
          '$_activityStarsPrefix$activityId', stars.clamp(0, 5));
      notifyListeners();
    } else {
      notifyListeners();
    }
  }

  int get totalStars {
    final prefs = _prefs;
    if (prefs == null) return 0;
    var total = 0;
    for (final key in prefs.getKeys()) {
      if (key.startsWith(_starsPrefix) ||
          key.startsWith(_activityStarsPrefix)) {
        total += prefs.getInt(key) ?? 0;
      }
    }
    return total;
  }

  bool isCompleted(String unitId) =>
      starsFor(unitId) > 0 || activityStarsFor(unitId) > 0;

  // --------------------------------------------------------------- desbloqueo

  bool get unlockAll => _prefs?.getBool(_unlockAllKey) ?? false;

  Future<void> setUnlockAll(bool value) async {
    await _prefs?.setBool(_unlockAllKey, value);
    notifyListeners();
  }

  /// ¿La unidad [index] de [sectionId] está desbloqueada?
  bool isUnitUnlocked(String sectionId, int index) {
    if (unlockAll) return true;
    if (!isSectionUnlocked(sectionId)) return false;
    if (index == 0) return true;
    final units = _unitsBySection[sectionId] ?? const [];
    if (index >= units.length) return false;
    return isCompleted(units[index - 1]);
  }

  /// ¿La sección [sectionId] está desbloqueada?
  /// [orderedSectionIds] es el orden global de secciones.
  bool isSectionUnlocked(
    String sectionId, {
    List<String> orderedSectionIds = CurriculumOrder.ids,
  }) {
    if (unlockAll) return true;
    final index = orderedSectionIds.indexOf(sectionId);
    if (index <= 0) return true;
    final previous = _unitsBySection[orderedSectionIds[index - 1]];
    if (previous == null || previous.isEmpty) return true;
    return previous.every(isCompleted);
  }

  /// Porcentaje de sección completado (0.0 - 1.0).
  double sectionProgress(String sectionId) {
    final units = _unitsBySection[sectionId];
    if (units == null || units.isEmpty) return 0;
    final done = units.where(isCompleted).length;
    return done / units.length;
  }

  /// Estrellas de una sección.
  int sectionStars(String sectionId) {
    final units = _unitsBySection[sectionId] ?? const [];
    return units.fold(
        0, (sum, u) => sum + starsFor(u) + activityStarsFor(u));
  }

  // ------------------------------------------------------ actividades EC0

  /// ¿El nivel [levelIndex] de Iniciación está desbloqueado?
  /// Un nivel se abre al completar (≥1 estrella) todas las actividades
  /// del nivel anterior.
  bool isActivityLevelUnlocked(int levelIndex) {
    if (unlockAll || levelIndex == 0) return true;
    if (levelIndex >= ActivityCatalog.levels.length) return false;
    final previous =
        ActivityCatalog.byLevel(ActivityCatalog.levels[levelIndex - 1]);
    return previous.every((a) => activityStarsFor(a.id) > 0);
  }

  /// ¿La actividad en [levelIndex]/[activityInLevel] está desbloqueada?
  /// Dentro del nivel se avanza en orden: la siguiente se abre al ganar
  /// al menos una estrella en la anterior.
  bool isActivityUnlocked(int levelIndex, int activityInLevel) {
    if (unlockAll) return true;
    if (!isActivityLevelUnlocked(levelIndex)) return false;
    if (activityInLevel == 0) return true;
    final level = ActivityCatalog.byLevel(ActivityCatalog.levels[levelIndex]);
    if (activityInLevel >= level.length) return false;
    return activityStarsFor(level[activityInLevel - 1].id) > 0;
  }

  /// Total de estrellas de Iniciación (máximo 75).
  int get initiationStars {
    var total = 0;
    for (final a in ActivityCatalog.all) {
      total += activityStarsFor(a.id);
    }
    return total;
  }
}

/// Orden global de las secciones EC0.
class CurriculumOrder {
  const CurriculumOrder._();

  static const ids = [
    'iniciacion',
    'vocales',
    'palabras1',
    'palabras2',
    'frases',
    'lecturas',
  ];
}