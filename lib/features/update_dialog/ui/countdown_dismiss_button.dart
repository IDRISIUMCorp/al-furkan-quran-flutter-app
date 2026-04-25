import 'dart:async';
import 'package:flutter/material.dart';

/// Animated countdown button that becomes tappable after N seconds.
class CountdownDismissButton extends StatefulWidget {
  const CountdownDismissButton({
    super.key,
    required this.seconds,
    required this.onDismiss,
    this.label = 'لاحقاً',
    this.showCountdown = true,
    this.color,
  });

  final int seconds;
  final VoidCallback onDismiss;
  final String label;
  final bool showCountdown;
  final Color? color;

  @override
  State<CountdownDismissButton> createState() => _CountdownDismissButtonState();
}

class _CountdownDismissButtonState extends State<CountdownDismissButton>
    with SingleTickerProviderStateMixin {
  late int _remaining;
  Timer? _timer;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    if (_remaining > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _remaining--);
        if (_remaining <= 0) {
          _timer?.cancel();
          _pulseController.forward();
        }
      });
    } else {
      _pulseController.forward();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  bool get _ready => _remaining <= 0;

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Colors.grey.shade400;

    return AnimatedOpacity(
      opacity: _ready ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 300),
      child: TextButton(
        onPressed: _ready ? widget.onDismiss : null,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: _ready ? color : color.withValues(alpha: 0.3),
            ),
          ),
        ),
        child: Text(
          _ready
              ? widget.label
              : widget.showCountdown
                  ? '${widget.label} ($_remaining)'
                  : widget.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _ready ? color : color.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}
