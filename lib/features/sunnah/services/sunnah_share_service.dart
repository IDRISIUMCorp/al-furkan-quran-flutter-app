import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/image_customization_model.dart';

/// خدمة مشاركة السنن
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
      await SharePlus.instance.share(
        ShareParams(text: text, subject: title),
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
      await SharePlus.instance.share(
        ShareParams(text: title, subject: type, files: [XFile(file.path)]),
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
}
