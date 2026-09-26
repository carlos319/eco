import 'package:flutter_test/flutter_test.dart';
import 'package:ec0_app/data/curriculum.dart';
import 'package:ec0_app/main.dart';
import 'package:ec0_app/models/models.dart';
import 'package:ec0_app/services/progress_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('El currículo carga con las secciones correctas', () {
    final units = Curriculum.unitIdsBySection();
    expect(units.length, 6);
    expect(units['iniciacion']!.length, 3);
    expect(units['vocales']!.length, 5);
    expect(units['palabras1']!.length, 15);
    expect(units['palabras2']!.length, 4);
    expect(units['frases']!.length, 6);
    expect(units['lecturas']!.length, 4);
  });

  test('Las palabras tienen sílabas y la letra f usa imágenes del ppsx', () {
    final f = Curriculum.letters().firstWhere((l) => l.letter == 'f');
    expect(f.syllables, ['fa', 'fe', 'fi', 'fo', 'fu']);
    final faro = f.pictureWords.firstWhere((w) => w.word == 'faro');
    expect(faro.syllables, ['fa', 'ro']);
    expect(faro.image, 'assets/images/faro.png');
  });

  test('Los ejercicios de la f cubren los 4 tipos pedidos', () {
    final f = Curriculum.letters().firstWhere((l) => l.letter == 'f');
    final types = f.exercises.map((e) => e.type).toSet();
    expect(types.contains(ExerciseType.pickWordForImage), true);
    expect(types.contains(ExerciseType.orderSyllables), true);
    expect(types.contains(ExerciseType.completeWord), true);
    expect(types.contains(ExerciseType.findLetterWords), true);
  });

  test('El progreso guarda estrellas y desbloquea por orden', () async {
    SharedPreferences.setMockInitialValues({});
    await ProgressService.instance.init();
    Curriculum.registerWith(ProgressService.instance);
    final progress = ProgressService.instance;

    // Iniciación desbloqueada desde el inicio; el resto, con candado.
    expect(progress.isUnitUnlocked('iniciacion', 0), true);
    expect(progress.isUnitUnlocked('vocales', 0), false);
    expect(progress.isUnitUnlocked('vocales', 1), false);

    // Completar toda la iniciación desbloquea la sección vocales (unidad 1).
    for (final id in Curriculum.unitIdsBySection()['iniciacion']!) {
      await progress.saveStars(id, 1);
    }
    expect(progress.isSectionUnlocked('vocales'), true);
    expect(progress.isUnitUnlocked('vocales', 0), true);
    expect(progress.isUnitUnlocked('vocales', 1), false); // falta unidad 1
    expect(progress.isSectionUnlocked('palabras1'), false);
    expect(progress.totalStars, greaterThanOrEqualTo(3));
  });

  testWidgets('La app arranca y muestra el menú principal', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await ProgressService.instance.init();
    Curriculum.registerWith(ProgressService.instance);

    await tester.pumpWidget(const Ec0App());
    await tester.pumpAndSettle();

    expect(find.text('EC0 · Aprende a leer'), findsOneWidget);
    expect(find.text('Iniciación'), findsOneWidget);
    expect(find.text('Vocales'), findsOneWidget);
    expect(find.text('Lee palabras'), findsOneWidget);
    expect(find.text('Lee frases'), findsOneWidget);
    // La última sección está más abajo: se hace scroll hasta ella.
    await tester.scrollUntilVisible(find.text('Lecturas'), 150);
    expect(find.text('Lecturas'), findsOneWidget);
  });
}
