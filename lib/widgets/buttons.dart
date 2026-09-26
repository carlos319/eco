import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// Botón grande estilo "3D" infantil (con sombra inferior oscura).
class BigButton extends StatelessWidget {
  const BigButton({
    super.key,
    required this.label,
    required this.color,
    required this.onPressed,
    this.icon,
    this.textColor,
    this.fontSize = 22,
    this.expanded = false,
    this.enabled = true,
  });

  final String label;
  final Color color;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? textColor;
  final double fontSize;
  final bool expanded;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isEnabled = enabled && onPressed != null;
    final text = textColor ??
        (isEnabled ? Colors.white : Colors.white.withOpacity(.7));
    final child = Material(
      color: isEnabled ? color : Colors.grey.shade400,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: isEnabled ? onPressed : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: text, size: fontSize + 4),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    color: text,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isEnabled
                ? color.withOpacity(.45)
                : Colors.black12, // sombra suave bajo el botón
            offset: const Offset(0, 6),
            blurRadius: 0,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Botón 3D pequeño para opciones (sílabas, palabras, emojis).
class ChipButton extends StatelessWidget {
  const ChipButton({
    super.key,
    required this.label,
    required this.color,
    required this.onPressed,
    this.fontSize = 26,
    this.selected = false,
    this.correct = false,
    this.wrong = false,
    this.enabled = true,
  });

  final String label;
  final Color color;
  final VoidCallback? onPressed;
  final double fontSize;
  final bool selected;
  final bool correct;
  final bool wrong;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isEnabled = enabled && onPressed != null;
    Color fill = color;
    if (wrong) fill = AppPalette.red;
    if (correct) fill = AppPalette.green;
    if (selected) fill = color.withOpacity(.55);
    if (!isEnabled && !wrong && !correct) {
      fill = Colors.grey.shade300;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.18),
            offset: const Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: fill,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: isEnabled ? onPressed : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: isEnabled || wrong || correct
                    ? Colors.white
                    : Colors.grey.shade500,
                height: 1.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
