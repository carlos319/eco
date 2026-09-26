import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/models.dart';
import '../services/tts_service.dart';

/// Muestra la imagen de una palabra (asset real) o un emoji grande.
class WordImage extends StatelessWidget {
  const WordImage({
    super.key,
    this.image,
    this.emoji,
    this.size = 120,
  });

  final String? image;
  final String? emoji;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (image != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          image!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _EmojiFallback(
            emoji: emoji ?? '🖼️',
            size: size,
          ),
        ),
      );
    }
    return _EmojiFallback(emoji: emoji ?? '📖', size: size);
  }
}

class _EmojiFallback extends StatelessWidget {
  const _EmojiFallback({required this.emoji, required this.size});

  final String emoji;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: FittedBox(child: Text(emoji)),
    );
  }
}

/// Palabra escrita por sílabas, con la letra objetivo resaltada.
class SyllableWord extends StatelessWidget {
  const SyllableWord({
    super.key,
    required this.syllables,
    this.highlightLetter,
    this.fontSize = 44,
    this.tappable = false,
    this.color,
    this.center = true,
    this.onDone,
  });

  final List<String> syllables;
  final String? highlightLetter;
  final double fontSize;
  final bool tappable;

  /// Color base del texto (para pantallas oscuras de lección).
  final Color? color;
  final bool center;

  /// Se llama cuando terminan de sonar todas las sílabas tocadas.
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    final base = color ?? AppPalette.ink;
    final children = <Widget>[];
    for (var i = 0; i < syllables.length; i++) {
      final syl = syllables[i];
      final isTarget =
          highlightLetter != null && syl.toLowerCase().contains(highlightLetter!);
      final style = TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: isTarget ? AppPalette.orangeDark : base,
        height: 1.15,
      );
      children.add(
        GestureDetector(
          onTap: tappable
              ? () async {
                  await TtsService.instance.speakSlow(syl);
                  onDone?.call();
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(syl, style: style),
          ),
        ),
      );
    }
    return Wrap(
      alignment: center ? WrapAlignment.center : WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}

/// Botón redondo de altavoz.
class SpeakerButton extends StatelessWidget {
  const SpeakerButton({
    super.key,
    this.onTap,
    this.size = 56,
    this.color,
  });

  final VoidCallback? onTap;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppPalette.sky;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.15),
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: c,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              Icons.volume_up_rounded,
              color: Colors.white,
              size: size * .5,
            ),
          ),
        ),
      ),
    );
  }
}

/// Fila de estrellas (rellenas/vacías).
class StarsRow extends StatelessWidget {
  const StarsRow({
    super.key,
    required this.stars,
    this.size = 28,
  });

  final int stars;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final filled = i < stars;
        return Icon(
          filled ? Icons.star_rounded : Icons.star_outline_rounded,
          color: filled ? AppPalette.yellow : Colors.grey.shade400,
          size: size,
        );
      }),
    );
  }
}

/// Tarjeta de palabra con imagen y texto en sílabas.
class WordCard extends StatelessWidget {
  const WordCard({
    super.key,
    required this.word,
    this.highlightLetter,
    this.imageSize = 96,
    this.fontScale = 1,
  });

  final WordItem word;
  final String? highlightLetter;
  final double imageSize;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          WordImage(
            image: word.image,
            emoji: word.emoji,
            size: imageSize,
          ),
          const SizedBox(height: 8),
          SyllableWord(
            syllables: word.syllables,
            highlightLetter: highlightLetter,
            fontSize: 24 * fontScale,
            tappable: true,
          ),
        ],
      ),
    );
  }
}
