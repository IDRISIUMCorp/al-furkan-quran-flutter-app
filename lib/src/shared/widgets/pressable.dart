import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Pressable widget — scale feedback on tap for all interactive elements
/// Every tappable element should use this for consistent haptic + visual feedback
/// Press state: scale 0.97 or opacity 0.8
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;
  final bool haptic;
  final Duration duration;

  const Pressable({
    required this.child,
    this.onTap,
    this.scaleDown = 0.97,
    this.haptic = true,
    this.duration = const Duration(milliseconds: 150),
    super.key,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..value = 1.0;
    _scaleAnimation = Tween<double>(begin: widget.scaleDown, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.haptic) {
      HapticFeedback.lightImpact();
    }
    _controller.reverse();
  }

  void _onTapUp(TapUpDetails _) {
    _controller.forward();
  }

  void _onTapCancel() {
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? _onTapDown : null,
      onTapUp: widget.onTap != null ? _onTapUp : null,
      onTapCancel: widget.onTap != null ? _onTapCancel : null,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// Pressable opacity variant — fades opacity on press instead of scaling
class PressableOpacity extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedOpacity;
  final bool haptic;
  final Duration duration;

  const PressableOpacity({
    required this.child,
    this.onTap,
    this.pressedOpacity = 0.8,
    this.haptic = true,
    this.duration = const Duration(milliseconds: 150),
    super.key,
  });

  @override
  State<PressableOpacity> createState() => _PressableOpacityState();
}

class _PressableOpacityState extends State<PressableOpacity> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails _) {
    if (widget.haptic) HapticFeedback.lightImpact();
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? _onTapDown : null,
      onTapUp: widget.onTap != null ? _onTapUp : null,
      onTapCancel: widget.onTap != null ? _onTapCancel : null,
      onTap: widget.onTap,
      child: AnimatedOpacity(
        opacity: _isPressed ? widget.pressedOpacity : 1.0,
        duration: widget.duration,
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}
