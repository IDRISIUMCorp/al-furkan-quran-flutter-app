import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// ✍️ نظام Typography - من آية (Ayah)
/// 
/// الفلسفة:
/// - أحجام أكبر من وحي (15sp بدل 14sp للـ body)
/// - line heights أسخى (1.9 بدل 1.8 للعربي)
/// - النتيجة: قراءة أسهل وأكثر راحة
class PrayerTextStyles {
  // ═══════════════════════════════════════════
  // ARABIC TEXT STYLES (من آية - أكبر)
  // ═══════════════════════════════════════════
  
  /// Display - للعناوين الكبيرة جداً (آية: 24sp, وحي: 28sp)
  static TextStyle arabicDisplay({Color? color}) => TextStyle(
        fontFamily: 'Cairo-Bold',
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        height: 1.4,
        letterSpacing: 0,
        color: color,
      );
  
  /// Headline - لعناوين الأقسام الرئيسية (آية: 20sp, وحي: 22sp)
  static TextStyle arabicHeadline({Color? color}) => TextStyle(
        fontFamily: 'Cairo-Bold',
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        height: 1.5,
        letterSpacing: 0,
        color: color,
      );
  
  /// Title - لعناوين الكروت والعناصر
  static TextStyle arabicTitle({Color? color}) => TextStyle(
        fontFamily: 'Cairo-SemiBold',
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        height: 1.5,
        letterSpacing: 0,
        color: color,
      );
  
  /// Body Large - للنصوص الكبيرة
  static TextStyle arabicBodyLarge({Color? color}) => TextStyle(
        fontFamily: 'Cairo-Regular',
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        height: 1.7,
        letterSpacing: 0,
        color: color,
      );
  
  /// Body - للنصوص العادية (آية: 15sp, وحي: 14sp)
  static TextStyle arabicBody({Color? color}) => TextStyle(
        fontFamily: 'Cairo-Regular',
        fontSize: 15.sp,
        fontWeight: FontWeight.w400,
        height: 1.7,
        letterSpacing: 0,
        color: color,
      );
  
  /// Caption - للنصوص الصغيرة والتوضيحات
  static TextStyle arabicCaption({Color? color}) => TextStyle(
        fontFamily: 'Cairo-Regular',
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0,
        color: color,
      );
  
  /// Label - للتسميات والأزرار (آية: 13sp, وحي: 14sp)
  static TextStyle arabicLabel({Color? color}) => TextStyle(
        fontFamily: 'Cairo-SemiBold',
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0,
        color: color,
      );
  
  // ═══════════════════════════════════════════
  // PRAYER-SPECIFIC ARABIC STYLES
  // ═══════════════════════════════════════════
  
  /// Prayer Name - أسماء الصلوات (الفجر، الظهر، إلخ)
  static TextStyle prayerName({Color? color, bool isBold = false}) => TextStyle(
        fontFamily: isBold ? 'Cairo-Bold' : 'Cairo-SemiBold',
        fontSize: 16.sp,
        fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
        height: 1.4,
        letterSpacing: 0,
        color: color,
      );
  
  /// Prayer Time - أوقات الصلاة (12:30 PM) (آية: 20sp, وحي: 20sp)
  static TextStyle prayerTime({Color? color, bool isLarge = false}) => TextStyle(
        fontFamily: 'Cairo-Bold',
        fontSize: isLarge ? 32.sp : 20.sp,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: 0.5,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
  
  /// Countdown Timer - العد التنازلي
  static TextStyle countdown({Color? color}) => TextStyle(
        fontFamily: 'Cairo-Bold',
        fontSize: 36.sp,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: 1,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
  
  /// Hijri Date - التاريخ الهجري
  static TextStyle hijriDate({Color? color, bool isLarge = false}) => TextStyle(
        fontFamily: 'Cairo-SemiBold',
        fontSize: isLarge ? 24.sp : 18.sp,
        fontWeight: FontWeight.w600,
        height: 1.5,
        letterSpacing: 0,
        color: color,
      );
  
  /// Hijri Month - اسم الشهر الهجري
  static TextStyle hijriMonth({Color? color}) => TextStyle(
        fontFamily: 'Cairo-Bold',
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        height: 1.4,
        letterSpacing: 0,
        color: color,
      );
  
  // ═══════════════════════════════════════════
  // LATIN/ENGLISH TEXT STYLES
  // ═══════════════════════════════════════════
  
  /// Display - Large headers
  static TextStyle display({Color? color}) => GoogleFonts.inter(
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.5,
        color: color,
      );
  
  /// Headline - Section headers
  static TextStyle headline({Color? color}) => GoogleFonts.inter(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.3,
        color: color,
      );
  
  /// Title - Card titles
  static TextStyle title({Color? color}) => GoogleFonts.inter(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0,
        color: color,
      );
  
  /// Body Large - Large body text
  static TextStyle bodyLarge({Color? color}) => GoogleFonts.inter(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0,
        color: color,
      );
  
  /// Body - Standard body text (آية: 15sp, وحي: 14sp)
  static TextStyle body({Color? color}) => GoogleFonts.inter(
        fontSize: 15.sp,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0,
        color: color,
      );
  
  /// Label - Button labels (آية: 13sp, وحي: 12sp)
  static TextStyle label({Color? color}) => GoogleFonts.inter(
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        height: 1.3,
        letterSpacing: 0.3,
        color: color,
      );
  
  /// Caption - Small text
  static TextStyle caption({Color? color}) => GoogleFonts.inter(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        height: 1.4,
        letterSpacing: 0.2,
        color: color,
      );
  
  // ═══════════════════════════════════════════
  // TIME & NUMBER STYLES (Tabular figures)
  // ═══════════════════════════════════════════
  
  /// Time Display - For digital clock style
  static TextStyle timeDisplay({Color? color}) => GoogleFonts.inter(
        fontSize: 48.sp,
        fontWeight: FontWeight.w700,
        height: 1.0,
        letterSpacing: 0,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
  
  /// Time Small - For compact time display
  static TextStyle timeSmall({Color? color}) => GoogleFonts.inter(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.5,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
  
  /// Number Display - For countdown and statistics
  static TextStyle numberDisplay({Color? color}) => GoogleFonts.inter(
        fontSize: 32.sp,
        fontWeight: FontWeight.w700,
        height: 1.0,
        letterSpacing: 0,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
  
  // ═══════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════
  
  /// Get text style based on type and language
  static TextStyle getStyle({
    required String type,
    required bool isArabic,
    Color? color,
    bool? isBold,
  }) {
    if (isArabic) {
      switch (type) {
        case 'display':
          return arabicDisplay(color: color);
        case 'headline':
          return arabicHeadline(color: color);
        case 'title':
          return arabicTitle(color: color);
        case 'bodyLarge':
          return arabicBodyLarge(color: color);
        case 'body':
          return arabicBody(color: color);
        case 'caption':
          return arabicCaption(color: color);
        case 'label':
          return arabicLabel(color: color);
        case 'prayerName':
          return prayerName(color: color, isBold: isBold ?? false);
        case 'prayerTime':
          return prayerTime(color: color);
        case 'hijriDate':
          return hijriDate(color: color);
        default:
          return arabicBody(color: color);
      }
    } else {
      switch (type) {
        case 'display':
          return display(color: color);
        case 'headline':
          return headline(color: color);
        case 'title':
          return title(color: color);
        case 'bodyLarge':
          return bodyLarge(color: color);
        case 'body':
          return body(color: color);
        case 'caption':
          return caption(color: color);
        case 'label':
          return label(color: color);
        default:
          return body(color: color);
      }
    }
  }
}
