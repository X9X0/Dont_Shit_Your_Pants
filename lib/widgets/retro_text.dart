import 'package:flutter/material.dart';

/// Shared retro styling helpers matching the original Flash game aesthetic.
class RetroColors {
  static const background = Color(0xFF1A1A2E);
  static const panelBg    = Color(0xFF16213E);
  static const border     = Color(0xFF4A9EFF);
  static const textMain   = Color(0xFFE0E0E0);
  static const textDim    = Color(0xFF888888);
  static const textGreen  = Color(0xFF4AFFA0);
  static const textRed    = Color(0xFFFF4A4A);
  static const textYellow = Color(0xFFFFD700);
  static const inputBg    = Color(0xFF0D0D1A);
  static const cursor     = Color(0xFF4A9EFF);
}

class RetroText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final TextAlign align;
  final bool mono;

  const RetroText(
    this.text, {
    super.key,
    this.fontSize = 14,
    this.color = RetroColors.textMain,
    this.align = TextAlign.left,
    this.mono = true,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: TextStyle(
        fontFamily: mono ? 'Uni05' : null,
        fontSize: fontSize,
        color: color,
        height: 1.4,
      ),
    );
  }
}

class RetroBorder extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final EdgeInsets padding;

  const RetroBorder({
    super.key,
    required this.child,
    this.borderColor = RetroColors.border,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: RetroColors.panelBg,
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: child,
    );
  }
}
