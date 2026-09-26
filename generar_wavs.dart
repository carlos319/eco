// Crea la carpeta assets/audio/ con 6 sonidos sintéticos.
// Ejecutar una sola vez desde la raíz del proyecto:
//   dart run generar_wavs.dart
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

void beep(String nombre,
    {double freq = 440, double dur = 0.25, double vol = 0.6, bool decay = true}) {
  const sr = 22050;
  final n = (sr * dur).round();
  final bytes = ByteData(44 + n * 2);

  void str(int offset, String s) {
    for (var i = 0; i < s.length; i++) {
      bytes.setUint8(offset + i, s.codeUnitAt(i));
    }
  }

  // Cabecera WAV estándar (PCM 16 bits, mono).
  str(0, 'RIFF');
  bytes.setUint32(4, 36 + n * 2, Endian.little);
  str(8, 'WAVE');
  str(12, 'fmt ');
  bytes.setUint32(16, 16, Endian.little);
  bytes.setUint16(20, 1, Endian.little);  // PCM
  bytes.setUint16(22, 1, Endian.little);  // mono
  bytes.setUint32(24, sr, Endian.little);
  bytes.setUint32(28, sr * 2, Endian.little);
  bytes.setUint16(32, 2, Endian.little);
  bytes.setUint16(34, 16, Endian.little);
  str(36, 'data');
  bytes.setUint32(40, n * 2, Endian.little);

  // Onda seno simple (beep).
  for (var i = 0; i < n; i++) {
    final t = i / sr;
    final env = decay ? exp(-3 * t / dur) : 1.0;
    final v = (vol * env * sin(2 * pi * freq * t) * 32767).toInt();
    bytes.setInt16(44 + i * 2, v, Endian.little);
  }

  File('assets/audio/$nombre').writeAsBytesSync(bytes.buffer.asUint8List());
  print('  ✓ $nombre');
}

void main() {
  Directory('assets/audio').createSync(recursive: true);
  print('Creando sonidos en assets/audio/ ...');
  beep('success.wav', freq: 660, dur: 0.30, decay: false); // acierto
  beep('error.wav', freq: 220, dur: 0.25);                 // error suave
  beep('pop.wav', freq: 880, dur: 0.08);                   // colocar pieza
  beep('star.wav', freq: 1320, dur: 0.15);                 // estrella ganada
  beep('drum.wav', freq: 110, dur: 0.18);                  // sílabas (A05)
  beep('tada.wav', freq: 523, dur: 0.50, decay: false);     // celebración final
  print('¡Listo! 6 sonidos creados.');
}