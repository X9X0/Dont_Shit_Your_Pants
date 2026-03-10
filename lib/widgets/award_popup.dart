import 'package:flutter/material.dart';
import 'retro_text.dart';

/// Fades in an award notification — mirrors the Tween(alpha 0→1) in the original.
class AwardPopup extends StatefulWidget {
  final String message;
  const AwardPopup({super.key, required this.message});

  @override
  State<AwardPopup> createState() => _AwardPopupState();
}

class _AwardPopupState extends State<AwardPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2A1A00),
          border: Border.all(color: RetroColors.textYellow, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: RetroText(
          '★ ${widget.message}',
          color: RetroColors.textYellow,
          fontSize: 12,
        ),
      ),
    );
  }
}
