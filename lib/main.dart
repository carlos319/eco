import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'data/curriculum.dart';
import 'screens/home_screen.dart';
import 'services/audio_service.dart';
import 'services/progress_service.dart';
import 'services/tts_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Progreso (estrellas y desbloqueos).
  await ProgressService.instance.init();
  Curriculum.registerWith(ProgressService.instance);

  // Voz en español (falla en silencio si el dispositivo no la tiene).
  await TtsService.instance.ensureInit();

  // Efectos de sonido del módulo de Iniciación (WAV locales).
  await AudioService.instance.ensureInit();

  runApp(const Ec0App());
}

class Ec0App extends StatelessWidget {
  const Ec0App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EC0 · Aprende a leer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const HomeScreen(),
    );
  }
}