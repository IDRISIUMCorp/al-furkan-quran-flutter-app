import 'package:adhan_dart/adhan_dart.dart';

/// 📝 أسماء الصلوات بالعربية والإنجليزية
class PrayerNames {
  /// Get Arabic name for prayer
  static String getArabicName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'الفجر';
      case Prayer.sunrise:
        return 'الشروق';
      case Prayer.dhuhr:
        return 'الظهر';
      case Prayer.asr:
        return 'العصر';
      case Prayer.maghrib:
        return 'المغرب';
      case Prayer.isha:
        return 'العشاء';
      default:
        return '';
    }
  }

  /// Get English name for prayer
  static String getEnglishName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'Fajr';
      case Prayer.sunrise:
        return 'Sunrise';
      case Prayer.dhuhr:
        return 'Dhuhr';
      case Prayer.asr:
        return 'Asr';
      case Prayer.maghrib:
        return 'Maghrib';
      case Prayer.isha:
        return 'Isha';
      default:
        return '';
    }
  }

  /// Get short Arabic name (for compact display)
  static String getShortArabicName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'فجر';
      case Prayer.sunrise:
        return 'شروق';
      case Prayer.dhuhr:
        return 'ظهر';
      case Prayer.asr:
        return 'عصر';
      case Prayer.maghrib:
        return 'مغرب';
      case Prayer.isha:
        return 'عشاء';
      default:
        return '';
    }
  }

  /// Get prayer description in Arabic
  static String getArabicDescription(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'صلاة الفجر - من طلوع الفجر إلى شروق الشمس';
      case Prayer.sunrise:
        return 'وقت الشروق - بداية النهار';
      case Prayer.dhuhr:
        return 'صلاة الظهر - من زوال الشمس إلى العصر';
      case Prayer.asr:
        return 'صلاة العصر - من منتصف النهار إلى المغرب';
      case Prayer.maghrib:
        return 'صلاة المغرب - من غروب الشمس إلى العشاء';
      case Prayer.isha:
        return 'صلاة العشاء - من مغيب الشفق إلى منتصف الليل';
      default:
        return '';
    }
  }

  /// Check if prayer is obligatory (فرض)
  static bool isObligatory(Prayer prayer) {
    return prayer != Prayer.sunrise;
  }

  /// Get prayer order number (1-6)
  static int getPrayerOrder(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 1;
      case Prayer.sunrise:
        return 2;
      case Prayer.dhuhr:
        return 3;
      case Prayer.asr:
        return 4;
      case Prayer.maghrib:
        return 5;
      case Prayer.isha:
        return 6;
      default:
        return 0;
    }
  }
}
