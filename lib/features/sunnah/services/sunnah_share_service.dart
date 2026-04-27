import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math' show cos, sin;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/sunnah_theme.dart';
import '../models/image_customization_model.dart';

/// 📤 خدمة مشاركة السنن
/// 
/// المميزات:
/// - مشاركة كنص منسق
/// - مشاركة كصورة احترافية
/// - مشاركة مباشرة عبر النظام
class SunnahShareService {
  /// مشاركة كنص
  static Future<void> shareAsText({
    required String title,
    required String description,
    String? evidence,
    required String type,
  }) async {
    final text = _formatText(
      title: title,
      description: description,
      evidence: evidence,
      type: type,
    );
    
    try {
      await Clipboard.setData(ClipboardData(text: text));
      await Share.share(
        text,
        subject: title,
      );
    } catch (e) {
      debugPrint('Error sharing as text: $e');
      rethrow;
    }
  }
  
  /// نسخ النص فقط
  static Future<void> copyToClipboard({
    required String title,
    required String description,
    String? evidence,
    required String type,
  }) async {
    final text = _formatText(
      title: title,
      description: description,
      evidence: evidence,
      type: type,
    );
    
    try {
      await Clipboard.setData(ClipboardData(text: text));
    } catch (e) {
      debugPrint('Error copying to clipboard: $e');
      rethrow;
    }
  }
  
  /// مشاركة كصورة
  static Future<void> shareAsImage({
    required BuildContext context,
    required String title,
    required String description,
    String? evidence,
    required String type,
    String? badgeText,
    Color? badgeColor,
    ImageCustomizationSettings? settings, // إضافة الإعدادات
  }) async {
    try {
      // استخدام الإعدادات المخصصة أو الافتراضية
      final imageSettings = settings ?? ImageCustomizationSettings();
      
      // إنشاء الصورة
      final imageBytes = await generateImageBytes(
        title: title,
        description: description,
        evidence: evidence,
        type: type,
        badgeText: badgeText,
        badgeColor: badgeColor,
        settings: imageSettings,
      );
      
      // حفظ الصورة مؤقتاً
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/sunnah_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(imageBytes);
      
      // مشاركة الصورة
      await Share.shareXFiles(
        [XFile(file.path)],
        text: title,
        subject: type,
      );
    } catch (e) {
      debugPrint('Error sharing as image: $e');
      rethrow;
    }
  }
  
  /// توليد bytes الصورة (للمعاينة والمشاركة)
  static Future<Uint8List> generateImageBytes({
    required String title,
    required String description,
    String? evidence,
    required String type,
    String? badgeText,
    Color? badgeColor,
    required ImageCustomizationSettings settings,
  }) async {
    return await _generateImage(
      title: title,
      description: description,
      evidence: evidence,
      type: type,
      badgeText: badgeText,
      badgeColor: badgeColor,
      settings: settings,
    );
  }
  
  /// تنسيق النص
  static String _formatText({
    required String title,
    required String description,
    String? evidence,
    required String type,
  }) {
    final buffer = StringBuffer();
    
    buffer.writeln('📿 $type');
    buffer.writeln();
    buffer.writeln('✨ $title');
    buffer.writeln();
    buffer.writeln(description);
    
    if (evidence != null && evidence.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('📖 الدليل:');
      buffer.writeln(evidence);
    }
    
    buffer.writeln();
    buffer.writeln('━━━━━━━━━━━━━━━');
    buffer.writeln('تطبيق الفرقان للقرآن الكريم');
    
    return buffer.toString();
  }
  
  /// إنشاء صورة احترافية - تصميم مطابق للمرجع
  static Future<Uint8List> _generateImage({
    required String title,
    required String description,
    String? evidence,
    required String type,
    String? badgeText,
    Color? badgeColor,
    required ImageCustomizationSettings settings,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    // أبعاد الصورة
    final size = settings.imageSize.dimensions;
    final width = size.width;
    
    // حساب scale factor بناءً على حجم الصورة
    final scale = settings.imageSize.scaleFactor;
    
    // الألوان والإعدادات
    final bgColor = settings.backgroundColor;
    final cardColor = Colors.white;
    final badgeColorFinal = badgeColor ?? settings.badgeColor;
    final titleColor = const Color(0xFF1A1A1A);
    final descColor = const Color(0xFF9CA3AF);
    final evidenceBgColor = badgeColorFinal.withValues(alpha: 0.08);
    
    // المسافات (متناسبة مع الحجم)
    final outerPadding = 40.0 * scale;
    final cardPadding = 50.0 * scale;
    final cardWidth = width - (outerPadding * 2);
    final contentWidth = cardWidth - (cardPadding * 2);
    
    // أحجام النصوص (متناسبة مع الحجم)
    final titleSize = 42.0 * scale;
    final descSize = 22.0 * scale;
    final evidenceSize = 19.0 * scale;
    final badgeTextSize = 18.0 * scale;
    final badgeLabelSize = 20.0 * scale;
    
    // حساب الارتفاع الديناميكي
    double contentHeight = cardPadding; // padding علوي
    
    // 1. البادج
    final badgeHeight = 50.0 * scale;
    contentHeight += badgeHeight;
    contentHeight += 35.0 * scale; // مسافة بعد البادج
    
    // 2. العنوان
    final titlePainter = TextPainter(
      text: TextSpan(
        text: title,
        style: GoogleFonts.cairo(
          fontSize: titleSize,
          fontWeight: FontWeight.w700,
          color: titleColor,
          height: 1.3,
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
    );
    titlePainter.layout(maxWidth: contentWidth);
    contentHeight += titlePainter.height;
    contentHeight += 30.0 * scale; // مسافة بعد العنوان
    
    // 3. الوصف
    final descPainter = TextPainter(
      text: TextSpan(
        text: description,
        style: GoogleFonts.cairo(
          fontSize: descSize,
          fontWeight: FontWeight.w500,
          color: descColor,
          height: 1.7,
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
    );
    descPainter.layout(maxWidth: contentWidth);
    contentHeight += descPainter.height;
    
    // 4. الدليل
    if (evidence != null && evidence.isNotEmpty) {
      contentHeight += 25.0 * scale; // مسافة قبل الدليل
      
      final evidencePainter = TextPainter(
        text: TextSpan(
          text: evidence,
          style: GoogleFonts.cairo(
            fontSize: evidenceSize,
            fontWeight: FontWeight.w600,
            color: badgeColorFinal,
            height: 1.6,
          ),
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
      );
      evidencePainter.layout(maxWidth: contentWidth - (70.0 * scale));
      contentHeight += evidencePainter.height + (40.0 * scale); // ارتفاع النص + padding الصندوق
    }
    
    contentHeight += cardPadding; // padding سفلي
    
    // الارتفاع الكلي
    final cardHeight = contentHeight;
    final totalHeight = cardHeight + (outerPadding * 2);
    
    // ═══════════════════════════════════════════
    // الرسم الفعلي
    // ═══════════════════════════════════════════
    
    // 1. الخلفية الخارجية
    final bgPaint = Paint()..color = bgColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, width, totalHeight), bgPaint);
    
    // 2. الكارد الأبيض
    final cardPaint = Paint()..color = cardColor;
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(outerPadding, outerPadding, cardWidth, cardHeight),
      Radius.circular(32.0 * scale),
    );
    canvas.drawRRect(cardRect, cardPaint);
    
    // 3. رسم المحتوى
    double currentY = outerPadding + cardPadding;
    final contentX = outerPadding + cardPadding;
    
    // البادج (دائرة + نص)
    final badgeRadius = 25.0 * scale;
    final badgePaint = Paint()..color = badgeColorFinal;
    canvas.drawCircle(
      Offset(contentX + badgeRadius, currentY + badgeRadius),
      badgeRadius,
      badgePaint,
    );
    
    final badgeTextPainter = TextPainter(
      text: TextSpan(
        text: badgeText ?? 'سنة',
        style: GoogleFonts.cairo(
          fontSize: badgeTextSize,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    );
    badgeTextPainter.layout();
    badgeTextPainter.paint(
      canvas,
      Offset(
        contentX + badgeRadius - (badgeTextPainter.width / 2),
        currentY + badgeRadius - (badgeTextPainter.height / 2),
      ),
    );
    
    // نص البادج (سنن الصلاة)
    final badgeLabelPainter = TextPainter(
      text: TextSpan(
        text: type,
        style: GoogleFonts.cairo(
          fontSize: badgeLabelSize,
          fontWeight: FontWeight.w700,
          color: titleColor,
        ),
      ),
      textDirection: TextDirection.rtl,
    );
    badgeLabelPainter.layout();
    badgeLabelPainter.paint(
      canvas,
      Offset(contentX + (60.0 * scale), currentY + (15.0 * scale)),
    );
    
    currentY += badgeHeight + (35.0 * scale); // ارتفاع البادج + مسافة
    
    // العنوان
    titlePainter.paint(canvas, Offset(contentX, currentY));
    currentY += titlePainter.height + (30.0 * scale);
    
    // الوصف
    descPainter.paint(canvas, Offset(contentX, currentY));
    currentY += descPainter.height;
    
    // الدليل
    if (evidence != null && evidence.isNotEmpty) {
      currentY += 25.0 * scale;
      
      final evidencePainter = TextPainter(
        text: TextSpan(
          text: evidence,
          style: GoogleFonts.cairo(
            fontSize: evidenceSize,
            fontWeight: FontWeight.w600,
            color: badgeColorFinal,
            height: 1.6,
          ),
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
      );
      evidencePainter.layout(maxWidth: contentWidth - (70.0 * scale));
      
      // صندوق الدليل
      final evidenceBoxPaint = Paint()..color = evidenceBgColor;
      final evidenceBoxRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          contentX,
          currentY - (10.0 * scale),
          contentWidth,
          evidencePainter.height + (40.0 * scale),
        ),
        Radius.circular(20.0 * scale),
      );
      canvas.drawRRect(evidenceBoxRect, evidenceBoxPaint);
      
      // أيقونة الدليل (دائرة صغيرة)
      final iconRadius = 15.0 * scale;
      final iconPaint = Paint()..color = badgeColorFinal;
      canvas.drawCircle(
        Offset(contentX + (25.0 * scale), currentY + (15.0 * scale)),
        iconRadius,
        iconPaint,
      );
      
      // علامة صح داخل الدائرة
      final checkPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0 * scale
        ..strokeCap = StrokeCap.round;
      
      final checkPath = Path();
      checkPath.moveTo(contentX + (18.0 * scale), currentY + (15.0 * scale));
      checkPath.lineTo(contentX + (23.0 * scale), currentY + (20.0 * scale));
      checkPath.lineTo(contentX + (32.0 * scale), currentY + (10.0 * scale));
      canvas.drawPath(checkPath, checkPaint);
      
      // نص الدليل
      evidencePainter.paint(
        canvas,
        Offset(contentX + (55.0 * scale), currentY + (5.0 * scale)),
      );
    }
    
    // تحويل إلى صورة
    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), totalHeight.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return byteData!.buffer.asUint8List();
  }
  
  /// رسم الخلفية حسب الإعدادات
  static void _drawBackground(Canvas canvas, double width, double height, ImageCustomizationSettings settings) {
    final bgPaint = Paint();
    
    switch (settings.backgroundType) {
      case BackgroundType.solid:
        bgPaint.color = settings.backgroundColor;
        canvas.drawRect(Rect.fromLTWH(0, 0, width, height), bgPaint);
        break;
        
      case BackgroundType.gradient:
        Gradient gradient;
        switch (settings.gradientDirection) {
          case GradientDirection.topToBottom:
            gradient = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [settings.gradientStartColor, settings.gradientEndColor],
            );
            break;
          case GradientDirection.bottomToTop:
            gradient = LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [settings.gradientStartColor, settings.gradientEndColor],
            );
            break;
          case GradientDirection.leftToRight:
            gradient = LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [settings.gradientStartColor, settings.gradientEndColor],
            );
            break;
          case GradientDirection.rightToLeft:
            gradient = LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [settings.gradientStartColor, settings.gradientEndColor],
            );
            break;
          case GradientDirection.diagonal:
            gradient = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [settings.gradientStartColor, settings.gradientEndColor],
            );
            break;
          case GradientDirection.radial:
            gradient = RadialGradient(
              colors: [settings.gradientStartColor, settings.gradientEndColor],
            );
            break;
        }
        
        bgPaint.shader = gradient.createShader(Rect.fromLTWH(0, 0, width, height));
        canvas.drawRect(Rect.fromLTWH(0, 0, width, height), bgPaint);
        break;
        
      case BackgroundType.pattern:
        // رسم الخلفية الأساسية
        bgPaint.color = settings.backgroundColor;
        canvas.drawRect(Rect.fromLTWH(0, 0, width, height), bgPaint);
        
        // رسم النمط
        _drawPattern(canvas, width, height, settings);
        break;
        
      case BackgroundType.image:
        // للمستقبل - يمكن إضافة صورة خلفية
        bgPaint.color = settings.backgroundColor;
        canvas.drawRect(Rect.fromLTWH(0, 0, width, height), bgPaint);
        break;
    }
  }
  
  /// رسم النمط
  static void _drawPattern(Canvas canvas, double width, double height, ImageCustomizationSettings settings) {
    final patternPaint = Paint()
      ..color = settings.decorationColor.withOpacity(settings.patternOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    switch (settings.patternType) {
      case PatternType.none:
        break;
        
      case PatternType.geometric:
        // شبكة هندسية
        for (double i = 0; i < width; i += 60) {
          canvas.drawLine(Offset(i, 0), Offset(i, height), patternPaint);
        }
        for (double i = 0; i < height; i += 60) {
          canvas.drawLine(Offset(0, i), Offset(width, i), patternPaint);
        }
        break;
        
      case PatternType.islamic:
        // نمط إسلامي بسيط
        for (double i = 0; i < width; i += 100) {
          for (double j = 0; j < height; j += 100) {
            canvas.drawCircle(Offset(i, j), 20, patternPaint);
          }
        }
        break;
        
      case PatternType.dots:
        // نقاط
        patternPaint.style = PaintingStyle.fill;
        for (double i = 0; i < width; i += 40) {
          for (double j = 0; j < height; j += 40) {
            canvas.drawCircle(Offset(i, j), 3, patternPaint);
          }
        }
        break;
        
      case PatternType.lines:
        // خطوط مائلة
        for (double i = -height; i < width; i += 40) {
          canvas.drawLine(
            Offset(i, 0),
            Offset(i + height, height),
            patternPaint,
          );
        }
        break;
        
      case PatternType.waves:
        // موجات
        final path = Path();
        for (double i = 0; i < height; i += 60) {
          path.moveTo(0, i);
          for (double j = 0; j < width; j += 40) {
            path.quadraticBezierTo(j + 20, i - 10, j + 40, i);
          }
        }
        canvas.drawPath(path, patternPaint);
        break;
    }
  }
  
  /// رسم الزخرفة
  static double _drawDecoration(
    Canvas canvas,
    double x,
    double y,
    double maxWidth,
    ImageCustomizationSettings settings,
    bool isTop,
  ) {
    if (settings.decorationType == DecorationType.none) return y;
    
    final paint = Paint()
      ..color = settings.decorationColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final centerX = x + maxWidth / 2;
    
    switch (settings.decorationType) {
      case DecorationType.none:
        break;
        
      case DecorationType.islamic:
        // زخرفة إسلامية بسيطة
        canvas.drawCircle(Offset(centerX, y + 20), 15, paint);
        canvas.drawLine(
          Offset(centerX - 40, y + 20),
          Offset(centerX - 20, y + 20),
          paint,
        );
        canvas.drawLine(
          Offset(centerX + 20, y + 20),
          Offset(centerX + 40, y + 20),
          paint,
        );
        break;
        
      case DecorationType.floral:
        // زخرفة زهرية
        for (int i = 0; i < 5; i++) {
          final angle = (i * 72) * 3.14159 / 180;
          final endX = centerX + 15 * cos(angle);
          final endY = y + 20 + 15 * sin(angle);
          canvas.drawLine(Offset(centerX, y + 20), Offset(endX, endY), paint);
        }
        break;
        
      case DecorationType.geometric:
        // زخرفة هندسية
        canvas.drawRect(
          Rect.fromCenter(center: Offset(centerX, y + 20), width: 30, height: 30),
          paint,
        );
        break;
        
      case DecorationType.simple:
        // خط بسيط
        canvas.drawLine(
          Offset(x + maxWidth * 0.3, y + 20),
          Offset(x + maxWidth * 0.7, y + 20),
          paint..strokeWidth = 3,
        );
        break;
    }
    
    return y + 40;
  }
  
  /// رسم نمط الخلفية
  static void _drawBackgroundPattern(Canvas canvas, double width, double height) {
    final paint = Paint()
      ..color = SunnahTheme.green.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    // رسم شبكة خفيفة
    for (double i = 0; i < width; i += 60) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, height),
        paint,
      );
    }
    
    for (double i = 0; i < height; i += 60) {
      canvas.drawLine(
        Offset(0, i),
        Offset(width, i),
        paint,
      );
    }
  }
  
  /// رسم الهيدر
  static Future<double> _drawHeader(
    Canvas canvas,
    String type,
    double x,
    double y,
    double maxWidth,
    ImageCustomizationSettings settings,
  ) async {
    // أيقونة
    if (settings.showIcon) {
      final iconPaint = Paint();
      
      switch (settings.headerStyle) {
        case HeaderStyle.simple:
          iconPaint.color = settings.headerColor;
          break;
        case HeaderStyle.gradient:
          iconPaint.shader = LinearGradient(
            colors: [settings.headerColor, settings.headerColor.withValues(alpha: 0.6)],
          ).createShader(Rect.fromCircle(center: Offset(x + 30, y + 30), radius: 30));
          break;
        case HeaderStyle.outlined:
          iconPaint.color = Colors.transparent;
          iconPaint.style = PaintingStyle.stroke;
          iconPaint.strokeWidth = 3;
          break;
        case HeaderStyle.filled:
          iconPaint.color = settings.headerColor;
          break;
      }
      
      canvas.drawCircle(Offset(x + 30, y + 30), 30, iconPaint);
      
      if (settings.headerStyle == HeaderStyle.outlined) {
        final fillPaint = Paint()..color = settings.headerColor;
        canvas.drawCircle(Offset(x + 30, y + 30), 15, fillPaint);
      }
    }
    
    // النص
    final textPainter = TextPainter(
      text: TextSpan(
        text: type,
        style: GoogleFonts.getFont(
          settings.fontFamily.replaceAll(' ', ''),
          fontSize: settings.titleFontSize * 0.7,
          fontWeight: FontWeight.w700,
          color: settings.headerColor,
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: settings.textAlign,
    );
    
    textPainter.layout(maxWidth: maxWidth - (settings.showIcon ? 80 : 0));
    textPainter.paint(canvas, Offset(x + (settings.showIcon ? 80 : 0), y + 10));
    
    return y + 60;
  }
  
  /// رسم البادج
  static double _drawBadge(
    Canvas canvas,
    String text,
    Color color,
    double x,
    double y,
    ImageCustomizationSettings settings,
  ) {
    double badgeRadius = 12;
    
    switch (settings.badgeStyle) {
      case BadgeStyle.rounded:
        badgeRadius = 12;
        break;
      case BadgeStyle.square:
        badgeRadius = 4;
        break;
      case BadgeStyle.pill:
        badgeRadius = 20;
        break;
      case BadgeStyle.minimal:
        badgeRadius = 6;
        break;
    }
    
    final badgePaint = Paint()..color = color.withValues(alpha: 0.15);
    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, 120, 40),
      Radius.circular(badgeRadius),
    );
    canvas.drawRRect(badgeRect, badgePaint);
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.getFont(
          settings.fontFamily.replaceAll(' ', ''),
          fontSize: settings.evidenceFontSize * 1.2,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    );
    
    textPainter.layout(maxWidth: 120);
    textPainter.paint(canvas, Offset(x + 10, y + 10));
    
    return y + 40;
  }
  
  /// رسم العنوان
  static Future<double> _drawTitle(
    Canvas canvas,
    String title,
    double x,
    double y,
    double maxWidth,
    ImageCustomizationSettings settings,
  ) async {
    final textPainter = TextPainter(
      text: TextSpan(
        text: title,
        style: GoogleFonts.getFont(
          settings.fontFamily.replaceAll(' ', ''),
          fontSize: settings.titleFontSize,
          fontWeight: FontWeight.w700,
          color: settings.titleColor,
          height: settings.lineHeight,
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: settings.textAlign,
    );
    
    textPainter.layout(maxWidth: maxWidth);
    textPainter.paint(canvas, Offset(x, y));
    
    return y + textPainter.height;
  }
  
  /// رسم الوصف
  static Future<double> _drawDescription(
    Canvas canvas,
    String description,
    double x,
    double y,
    double maxWidth,
    ImageCustomizationSettings settings,
  ) async {
    final textPainter = TextPainter(
      text: TextSpan(
        text: description,
        style: GoogleFonts.getFont(
          settings.fontFamily.replaceAll(' ', ''),
          fontSize: settings.descriptionFontSize,
          fontWeight: FontWeight.w600,
          color: settings.descriptionColor,
          height: settings.lineHeight,
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: settings.textAlign,
    );
    
    textPainter.layout(maxWidth: maxWidth);
    textPainter.paint(canvas, Offset(x, y));
    
    return y + textPainter.height;
  }
  
  /// رسم الدليل
  static Future<double> _drawEvidence(
    Canvas canvas,
    String evidence,
    double x,
    double y,
    double maxWidth,
    ImageCustomizationSettings settings,
  ) async {
    // حساب ارتفاع النص أولاً
    final textPainter = TextPainter(
      text: TextSpan(
        text: evidence,
        style: GoogleFonts.getFont(
          settings.fontFamily.replaceAll(' ', ''),
          fontSize: settings.evidenceFontSize,
          fontWeight: FontWeight.w600,
          color: settings.evidenceColor,
          height: settings.lineHeight,
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: settings.textAlign,
    );
    
    textPainter.layout(maxWidth: maxWidth - 60);
    
    // صندوق الدليل بارتفاع مناسب (padding صغير جداً)
    final boxPadding = 12.0; // padding 6 من كل جهة
    final boxHeight = textPainter.height + boxPadding;
    final boxPaint = Paint()..color = settings.evidenceColor.withValues(alpha: 0.1);
    final boxRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x - 20, y - 6, maxWidth + 40, boxHeight),
      Radius.circular(settings.cardRadius * 0.6),
    );
    canvas.drawRRect(boxRect, boxPaint);
    
    // أيقونة التحقق
    final iconPaint = Paint()..color = settings.evidenceColor;
    canvas.drawCircle(Offset(x + 20, y + 12), 12, iconPaint);
    
    // النص
    textPainter.paint(canvas, Offset(x + 45, y));
    
    return y + textPainter.height; // إرجاع ارتفاع النص فقط
  }
  
  // ═══════════════════════════════════════════
  // SIMPLE DRAWING FUNCTIONS - تصميم بسيط ونظيف
  // ═══════════════════════════════════════════
  
  /// رسم الزخرفة العلوية البسيطة
  static void _drawTopDecoration(Canvas canvas, double centerX, double y, ImageCustomizationSettings settings) {
    final paint = Paint()
      ..color = settings.decorationColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // دائرة صغيرة في المنتصف
    canvas.drawCircle(Offset(centerX, y), 8, paint);
    
    // خطوط على الجانبين
    canvas.drawLine(Offset(centerX - 60, y), Offset(centerX - 20, y), paint);
    canvas.drawLine(Offset(centerX + 20, y), Offset(centerX + 60, y), paint);
  }
  
  /// رسم الزخرفة السفلية البسيطة
  static void _drawBottomDecoration(Canvas canvas, double centerX, double y, ImageCustomizationSettings settings) {
    final paint = Paint()
      ..color = settings.decorationColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // دائرة صغيرة في المنتصف
    canvas.drawCircle(Offset(centerX, y), 8, paint);
    
    // خطوط على الجانبين
    canvas.drawLine(Offset(centerX - 60, y), Offset(centerX - 20, y), paint);
    canvas.drawLine(Offset(centerX + 20, y), Offset(centerX + 60, y), paint);
  }
  
  /// رسم البادج البسيط
  static double _drawBadgeSimple(
    Canvas canvas,
    String text,
    Color color,
    double x,
    double y,
    ImageCustomizationSettings settings,
  ) {
    // دائرة صغيرة + نص
    final circlePaint = Paint()..color = color;
    canvas.drawCircle(Offset(x + 15, y + 15), 12, circlePaint);
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.getFont(
          settings.fontFamily.replaceAll(' ', ''),
          fontSize: settings.evidenceFontSize,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
      textDirection: TextDirection.rtl,
    );
    
    textPainter.layout();
    textPainter.paint(canvas, Offset(x + 35, y + 5));
    
    return y + 30;
  }
  
  /// رسم العنوان البسيط
  static Future<double> _drawTitleSimple(
    Canvas canvas,
    String title,
    double x,
    double y,
    double maxWidth,
    ImageCustomizationSettings settings,
  ) async {
    final textPainter = TextPainter(
      text: TextSpan(
        text: title,
        style: GoogleFonts.getFont(
          settings.fontFamily.replaceAll(' ', ''),
          fontSize: settings.titleFontSize,
          fontWeight: FontWeight.w700,
          color: settings.titleColor,
          height: 1.4,
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: settings.textAlign,
    );
    
    textPainter.layout(maxWidth: maxWidth);
    textPainter.paint(canvas, Offset(x, y));
    
    return y + textPainter.height;
  }
  
  /// رسم الوصف البسيط
  static Future<double> _drawDescriptionSimple(
    Canvas canvas,
    String description,
    double x,
    double y,
    double maxWidth,
    ImageCustomizationSettings settings,
  ) async {
    final textPainter = TextPainter(
      text: TextSpan(
        text: description,
        style: GoogleFonts.getFont(
          settings.fontFamily.replaceAll(' ', ''),
          fontSize: settings.descriptionFontSize,
          fontWeight: FontWeight.w600,
          color: settings.descriptionColor,
          height: 1.6,
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: settings.textAlign,
    );
    
    textPainter.layout(maxWidth: maxWidth);
    textPainter.paint(canvas, Offset(x, y));
    
    return y + textPainter.height;
  }
  
  /// رسم الدليل البسيط - بدون مسافات كبيرة
  static Future<double> _drawEvidenceSimple(
    Canvas canvas,
    String evidence,
    double x,
    double y,
    double maxWidth,
    ImageCustomizationSettings settings,
  ) async {
    // حساب ارتفاع النص
    final textPainter = TextPainter(
      text: TextSpan(
        text: evidence,
        style: GoogleFonts.getFont(
          settings.fontFamily.replaceAll(' ', ''),
          fontSize: settings.evidenceFontSize,
          fontWeight: FontWeight.w600,
          color: settings.evidenceColor,
          height: 1.4, // قللت من 1.5 إلى 1.4
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: settings.textAlign,
    );
    
    textPainter.layout(maxWidth: maxWidth - 50);
    
    // صندوق بسيط بدون padding كبير
    final boxPaint = Paint()..color = settings.evidenceColor.withValues(alpha: 0.08);
    final boxRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x - 15, y - 6, maxWidth + 30, textPainter.height + 12), // قللت الـ padding من 16 إلى 12
      Radius.circular(12),
    );
    canvas.drawRRect(boxRect, boxPaint);
    
    // أيقونة صغيرة
    final iconPaint = Paint()..color = settings.evidenceColor;
    canvas.drawCircle(Offset(x + 10, y + 8), 8, iconPaint); // عدلت الـ y من 10 إلى 8
    
    // النص
    textPainter.paint(canvas, Offset(x + 30, y));
    
    return y + textPainter.height; // بدون padding زيادة
  }
  
  /// رسم الفوتر البسيط
  static Future<void> _drawFooterSimple(
    Canvas canvas,
    double width,
    double y,
    ImageCustomizationSettings settings,
  ) async {
    // خط فاصل بسيط
    final linePaint = Paint()
      ..color = settings.borderColor.withValues(alpha: 0.3)
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(width * 0.3, y),
      Offset(width * 0.7, y),
      linePaint,
    );
    
    // النص
    final textPainter = TextPainter(
      text: TextSpan(
        text: settings.footerText,
        style: GoogleFonts.getFont(
          settings.fontFamily.replaceAll(' ', ''),
          fontSize: settings.footerFontSize,
          fontWeight: FontWeight.w600,
          color: settings.footerColor,
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    );
    
    textPainter.layout(maxWidth: width);
    textPainter.paint(canvas, Offset(0, y + 20));
  }
  
  /// رسم الفوتر
  static Future<void> _drawFooter(
    Canvas canvas,
    double width,
    double y,
    ImageCustomizationSettings settings,
  ) async {
    // خط فاصل
    final linePaint = Paint()
      ..color = settings.borderColor
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(width * 0.2, y),
      Offset(width * 0.8, y),
      linePaint,
    );
    
    // النص
    final textPainter = TextPainter(
      text: TextSpan(
        text: settings.footerText,
        style: GoogleFonts.getFont(
          settings.fontFamily.replaceAll(' ', ''),
          fontSize: settings.footerFontSize,
          fontWeight: FontWeight.w700,
          color: settings.footerColor,
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    );
    
    textPainter.layout(maxWidth: width);
    textPainter.paint(canvas, Offset(0, y + 30));
  }
}

