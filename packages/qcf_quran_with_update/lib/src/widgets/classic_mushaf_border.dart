import 'package:flutter/material.dart';
import '../qcf_theme_data.dart';

/// Classic Islamic border frame with decorative corner ornaments.
///
/// Used when [QcfThemeData.useClassicBorder] is true to render
/// traditional mushaf page borders similar to printed Quran pages.
class ClassicMushafBorder extends StatelessWidget {
  final QcfThemeData theme;
  final Widget child;

  const ClassicMushafBorder({
    super.key,
    required this.theme,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!theme.useClassicBorder) return child;

    return Container(
      decoration: BoxDecoration(
        color: theme.classicPageBackground,
        border: Border.all(
          color: theme.borderColor,
          width: theme.borderWidth,
        ),
      ),
      child: Stack(
        children: [
          // Main content
          child,
          // Corner ornaments
          Positioned(
            top: 0,
            left: 0,
            child: _CornerOrnament(
              color: theme.ornamentColor,
              size: 32,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: _CornerOrnament(
              color: theme.ornamentColor,
              size: 32,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: _CornerOrnament(
              color: theme.ornamentColor,
              size: 32,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: _CornerOrnament(
              color: theme.ornamentColor,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

/// Decorative Islamic geometric pattern for corner ornaments.
class _CornerOrnament extends StatelessWidget {
  final Color color;
  final double size;

  const _CornerOrnament({
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CornerOrnamentPainter(color: color),
    );
  }
}

class _CornerOrnamentPainter extends CustomPainter {
  final Color color;

  _CornerOrnamentPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    final double s = size.shortestSide;

    // Islamic geometric pattern - simple interlaced lines
    path.moveTo(0, s * 0.3);
    path.lineTo(s * 0.3, 0);
    path.moveTo(0, s * 0.5);
    path.lineTo(s * 0.5, 0);
    path.moveTo(0, s * 0.7);
    path.lineTo(s * 0.7, 0);
    
    path.moveTo(s * 0.3, s);
    path.lineTo(s, s * 0.3);
    path.moveTo(s * 0.5, s);
    path.lineTo(s, s * 0.5);
    path.moveTo(s * 0.7, s);
    path.lineTo(s, s * 0.7);

    // Inner diamond pattern
    final center = Offset(s * 0.5, s * 0.5);
    final diamondSize = s * 0.2;
    path.moveTo(center.dx, center.dy - diamondSize);
    path.lineTo(center.dx + diamondSize, center.dy);
    path.lineTo(center.dx, center.dy + diamondSize);
    path.lineTo(center.dx - diamondSize, center.dy);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CornerOrnamentPainter oldDelegate) => false;
}
