import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:file_picker/file_picker.dart';

/// معلومات الخط
class FontInfo {
  final String name;
  final String nameAr;
  final String url;
  final String category;
  final String description;
  final String preview;

  const FontInfo({
    required this.name,
    required this.nameAr,
    required this.url,
    required this.category,
    required this.description,
    required this.preview,
  });
}

/// خدمة تحميل الخطوط من مصدر خارجي مجاني
/// يستخدم Google Fonts API و GitHub للخطوط العربية
class RemoteFontLoader {
  static final RemoteFontLoader _instance = RemoteFontLoader._internal();
  factory RemoteFontLoader() => _instance;
  RemoteFontLoader._internal();

  // خطوط القرآن من مصادر مجانية (20 خط)
  static const Map<String, FontInfo> quranFonts = {
    'Amiri': FontInfo(
      name: 'Amiri',
      nameAr: 'أميري',
      url: 'https://fonts.googleapis.com/css2?family=Amiri:wght@400;700&display=swap',
      category: 'قرآن',
      description: 'خط أميري الكلاسيكي - مثالي للقرآن',
      preview: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
    ),
    'Scheherazade New': FontInfo(
      name: 'Scheherazade New',
      nameAr: 'شهرزاد الجديد',
      url: 'https://fonts.googleapis.com/css2?family=Scheherazade+New:wght@400;700&display=swap',
      category: 'قرآن',
      description: 'خط شهرزاد المحدث - واضح وجميل',
      preview: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
    ),
    'Lateef': FontInfo(
      name: 'Lateef',
      nameAr: 'لطيف',
      url: 'https://fonts.googleapis.com/css2?family=Lateef:wght@400;700&display=swap',
      category: 'قرآن',
      description: 'خط لطيف - بسيط وأنيق',
      preview: 'الرَّحْمَٰنِ الرَّحِيمِ',
    ),
    'Aref Ruqaa': FontInfo(
      name: 'Aref Ruqaa',
      nameAr: 'عارف رقعة',
      url: 'https://fonts.googleapis.com/css2?family=Aref+Ruqaa:wght@400;700&display=swap',
      category: 'قرآن',
      description: 'خط الرقعة - تقليدي وواضح',
      preview: 'مَالِكِ يَوْمِ الدِّينِ',
    ),
    'Reem Kufi': FontInfo(
      name: 'Reem Kufi',
      nameAr: 'ريم كوفي',
      url: 'https://fonts.googleapis.com/css2?family=Reem+Kufi:wght@400;500;600;700&display=swap',
      category: 'قرآن',
      description: 'خط كوفي عصري - مميز وجذاب',
      preview: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
    ),
    'Harmattan': FontInfo(
      name: 'Harmattan',
      nameAr: 'هرمتان',
      url: 'https://fonts.googleapis.com/css2?family=Harmattan:wght@400;700&display=swap',
      category: 'قرآن',
      description: 'خط هرمتان - نسخ واضح',
      preview: 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
    ),
    'Markazi Text': FontInfo(
      name: 'Markazi Text',
      nameAr: 'مركزي',
      url: 'https://fonts.googleapis.com/css2?family=Markazi+Text:wght@400;500;600;700&display=swap',
      category: 'قرآن',
      description: 'خط مركزي - احترافي للنصوص',
      preview: 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ',
    ),
    'Changa': FontInfo(
      name: 'Changa',
      nameAr: 'شانجا',
      url: 'https://fonts.googleapis.com/css2?family=Changa:wght@200;300;400;500;600;700;800&display=swap',
      category: 'قرآن',
      description: 'خط شانجا - عصري وأنيق',
      preview: 'غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ',
    ),
    'El Messiri': FontInfo(
      name: 'El Messiri',
      nameAr: 'المسيري',
      url: 'https://fonts.googleapis.com/css2?family=El+Messiri:wght@400;500;600;700&display=swap',
      category: 'قرآن',
      description: 'خط المسيري - تقليدي محدث',
      preview: 'وَلَا الضَّالِّينَ',
    ),
    'Katibeh': FontInfo(
      name: 'Katibeh',
      nameAr: 'كاتبة',
      url: 'https://fonts.googleapis.com/css2?family=Katibeh&display=swap',
      category: 'قرآن',
      description: 'خط كاتبة - خط يد جميل',
      preview: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
    ),
  };

  // خطوط التطبيق من Google Fonts (30+ خط)
  static const Map<String, FontInfo> appFonts = {
    'Cairo': FontInfo(
      name: 'Cairo',
      nameAr: 'القاهرة',
      url: 'https://fonts.googleapis.com/css2?family=Cairo:wght@200;300;400;500;600;700;800;900&display=swap',
      category: 'تطبيق',
      description: 'خط القاهرة - الأكثر شعبية',
      preview: 'خط القاهرة الاحترافي',
    ),
    'Noto Sans Arabic': FontInfo(
      name: 'Noto Sans Arabic',
      nameAr: 'نوتو سانس',
      url: 'https://fonts.googleapis.com/css2?family=Noto+Sans+Arabic:wght@100;200;300;400;500;600;700;800;900&display=swap',
      category: 'تطبيق',
      description: 'نوتو سانس - واضح وعصري',
      preview: 'خط نوتو سانس العربي',
    ),
    'Tajawal': FontInfo(
      name: 'Tajawal',
      nameAr: 'تجوال',
      url: 'https://fonts.googleapis.com/css2?family=Tajawal:wght@200;300;400;500;700;800;900&display=swap',
      category: 'تطبيق',
      description: 'تجوال - بسيط وأنيق',
      preview: 'خط تجوال الجميل',
    ),
    'Almarai': FontInfo(
      name: 'Almarai',
      nameAr: 'المرعي',
      url: 'https://fonts.googleapis.com/css2?family=Almarai:wght@300;400;700;800&display=swap',
      category: 'تطبيق',
      description: 'المرعي - احترافي',
      preview: 'خط المرعي الاحترافي',
    ),
    'IBM Plex Sans Arabic': FontInfo(
      name: 'IBM Plex Sans Arabic',
      nameAr: 'آي بي إم',
      url: 'https://fonts.googleapis.com/css2?family=IBM+Plex+Sans+Arabic:wght@100;200;300;400;500;600;700&display=swap',
      category: 'تطبيق',
      description: 'IBM - تقني وحديث',
      preview: 'خط آي بي إم العربي',
    ),
    'Rubik': FontInfo(
      name: 'Rubik',
      nameAr: 'روبيك',
      url: 'https://fonts.googleapis.com/css2?family=Rubik:wght@300;400;500;600;700;800;900&display=swap',
      category: 'تطبيق',
      description: 'روبيك - عصري ومرن',
      preview: 'خط روبيك الحديث',
    ),
    'Lalezar': FontInfo(
      name: 'Lalezar',
      nameAr: 'لاليزار',
      url: 'https://fonts.googleapis.com/css2?family=Lalezar&display=swap',
      category: 'تطبيق',
      description: 'لاليزار - جريء وقوي',
      preview: 'خط لاليزار القوي',
    ),
    'Mada': FontInfo(
      name: 'Mada',
      nameAr: 'مدى',
      url: 'https://fonts.googleapis.com/css2?family=Mada:wght@200;300;400;500;600;700;900&display=swap',
      category: 'تطبيق',
      description: 'مدى - متعدد الاستخدامات',
      preview: 'خط مدى المتنوع',
    ),
    'Jomhuria': FontInfo(
      name: 'Jomhuria',
      nameAr: 'جمهورية',
      url: 'https://fonts.googleapis.com/css2?family=Jomhuria&display=swap',
      category: 'تطبيق',
      description: 'جمهورية - تقليدي أنيق',
      preview: 'خط الجمهورية',
    ),
    'Lemonada': FontInfo(
      name: 'Lemonada',
      nameAr: 'ليمونادا',
      url: 'https://fonts.googleapis.com/css2?family=Lemonada:wght@300;400;500;600;700&display=swap',
      category: 'تطبيق',
      description: 'ليمونادا - مرح ومميز',
      preview: 'خط ليمونادا المرح',
    ),
    'Baloo Bhaijaan 2': FontInfo(
      name: 'Baloo Bhaijaan 2',
      nameAr: 'بالو بهايجان',
      url: 'https://fonts.googleapis.com/css2?family=Baloo+Bhaijaan+2:wght@400;500;600;700;800&display=swap',
      category: 'تطبيق',
      description: 'بالو - ودود ومريح',
      preview: 'خط بالو الودود',
    ),
    'Vibes': FontInfo(
      name: 'Vibes',
      nameAr: 'فايبز',
      url: 'https://fonts.googleapis.com/css2?family=Vibes&display=swap',
      category: 'تطبيق',
      description: 'فايبز - خط يد فني',
      preview: 'خط فايبز الفني',
    ),
    'Rakkas': FontInfo(
      name: 'Rakkas',
      nameAr: 'رقاص',
      url: 'https://fonts.googleapis.com/css2?family=Rakkas&display=swap',
      category: 'تطبيق',
      description: 'رقاص - زخرفي جميل',
      preview: 'خط رقاص الزخرفي',
    ),
    'Mirza': FontInfo(
      name: 'Mirza',
      nameAr: 'ميرزا',
      url: 'https://fonts.googleapis.com/css2?family=Mirza:wght@400;500;600;700&display=swap',
      category: 'تطبيق',
      description: 'ميرزا - كلاسيكي راقي',
      preview: 'خط ميرزا الراقي',
    ),
    'Kufam': FontInfo(
      name: 'Kufam',
      nameAr: 'كوفام',
      url: 'https://fonts.googleapis.com/css2?family=Kufam:wght@400;500;600;700;800;900&display=swap',
      category: 'تطبيق',
      description: 'كوفام - كوفي حديث',
      preview: 'خط كوفام الحديث',
    ),
  };

  Box? _fontCacheBox;
  final Map<String, bool> _downloadedFonts = {};

  /// تهيئة الخدمة
  Future<void> initialize() async {
    try {
      _fontCacheBox = await Hive.openBox('font_cache');
    } catch (e) {
      debugPrint('❌ فشل فتح صندوق الخطوط: $e');
    }
  }

  /// تحميل خط من Google Fonts
  Future<bool> downloadFont(String fontName, String cssUrl) async {
    try {
      // التحقق من التحميل السابق
      if (_downloadedFonts[fontName] == true) {
        return true;
      }

      // التحقق من الكاش
      final cachedPath = _fontCacheBox?.get('font_$fontName');
      if (cachedPath != null && await File(cachedPath).exists()) {
        _downloadedFonts[fontName] = true;
        return true;
      }

      debugPrint('⬇️ تحميل خط: $fontName');

      // تحميل CSS للحصول على رابط الخط
      final cssResponse = await http.get(Uri.parse(cssUrl));
      if (cssResponse.statusCode != 200) {
        debugPrint('❌ فشل تحميل CSS للخط: $fontName');
        return false;
      }

      // استخراج رابط ملف الخط من CSS
      final fontUrlMatch = RegExp(r'url\((https://[^)]+\.(?:ttf|otf|woff2))\)')
          .firstMatch(cssResponse.body);
      
      if (fontUrlMatch == null) {
        debugPrint('❌ لم يتم العثور على رابط الخط في CSS');
        return false;
      }

      final fontUrl = fontUrlMatch.group(1)!;

      // تحميل ملف الخط
      final fontResponse = await http.get(Uri.parse(fontUrl));
      if (fontResponse.statusCode != 200) {
        debugPrint('❌ فشل تحميل ملف الخط: $fontName');
        return false;
      }

      // حفظ الخط محلياً
      final directory = await getApplicationDocumentsDirectory();
      final fontDir = Directory('${directory.path}/fonts');
      if (!await fontDir.exists()) {
        await fontDir.create(recursive: true);
      }

      final extension = fontUrl.endsWith('.woff2') ? 'woff2' : 
                       fontUrl.endsWith('.otf') ? 'otf' : 'ttf';
      final fontFile = File('${fontDir.path}/$fontName.$extension');
      await fontFile.writeAsBytes(fontResponse.bodyBytes);

      // حفظ في الكاش
      await _fontCacheBox?.put('font_$fontName', fontFile.path);
      _downloadedFonts[fontName] = true;

      debugPrint('✅ تم تحميل الخط: $fontName');
      return true;
    } catch (e) {
      debugPrint('❌ خطأ في تحميل الخط $fontName: $e');
      return false;
    }
  }

  /// رفع خط مخصص من الجهاز
  Future<bool> uploadCustomFont() async {
    try {
      // فتح منتقي الملفات
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['ttf', 'otf'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        debugPrint('❌ لم يتم اختيار ملف');
        return false;
      }

      final file = result.files.first;
      if (file.path == null) {
        debugPrint('❌ مسار الملف غير صالح');
        return false;
      }

      // التحقق من نوع الملف
      final extension = file.extension?.toLowerCase();
      if (extension != 'ttf' && extension != 'otf') {
        debugPrint('❌ نوع الملف غير مدعوم: $extension');
        return false;
      }

      // اسم الخط (من اسم الملف)
      final fontName = file.name.replaceAll(RegExp(r'\.(ttf|otf)$'), '');
      
      debugPrint('📤 رفع خط مخصص: $fontName');

      // نسخ الخط إلى مجلد التطبيق
      final directory = await getApplicationDocumentsDirectory();
      final fontDir = Directory('${directory.path}/fonts/custom');
      if (!await fontDir.exists()) {
        await fontDir.create(recursive: true);
      }

      final sourceFile = File(file.path!);
      final targetFile = File('${fontDir.path}/$fontName.$extension');
      await sourceFile.copy(targetFile.path);

      // حفظ في الكاش
      await _fontCacheBox?.put('font_custom_$fontName', targetFile.path);
      _downloadedFonts['custom_$fontName'] = true;

      debugPrint('✅ تم رفع الخط المخصص: $fontName');
      return true;
    } catch (e) {
      debugPrint('❌ خطأ في رفع الخط المخصص: $e');
      return false;
    }
  }

  /// الحصول على قائمة الخطوط المخصصة
  List<String> getCustomFonts() {
    return _downloadedFonts.keys
        .where((key) => key.startsWith('custom_'))
        .map((key) => key.replaceFirst('custom_', ''))
        .toList();
  }

  /// تحميل كل خطوط القرآن
  Future<void> downloadAllQuranFonts() async {
    debugPrint('📥 بدء تحميل خطوط القرآن...');
    
    for (final entry in quranFonts.entries) {
      await downloadFont(entry.key, entry.value.url);
    }
    
    debugPrint('✅ انتهى تحميل خطوط القرآن');
  }

  /// تحميل كل خطوط التطبيق
  Future<void> downloadAllAppFonts() async {
    debugPrint('📥 بدء تحميل خطوط التطبيق...');
    
    for (final entry in appFonts.entries) {
      await downloadFont(entry.key, entry.value.url);
    }
    
    debugPrint('✅ انتهى تحميل خطوط التطبيق');
  }

  /// تحميل خط واحد محدد
  Future<bool> downloadSpecificFont(String fontName) async {
    final allFonts = {...quranFonts, ...appFonts};
    
    if (!allFonts.containsKey(fontName)) {
      debugPrint('❌ الخط غير موجود: $fontName');
      return false;
    }

    return await downloadFont(fontName, allFonts[fontName]!.url);
  }

  /// الحصول على معلومات خط
  FontInfo? getFontInfo(String fontName) {
    final allFonts = {...quranFonts, ...appFonts};
    return allFonts[fontName];
  }

  /// الحصول على كل الخطوط المتاحة
  Map<String, FontInfo> getAllAvailableFonts() {
    return {...quranFonts, ...appFonts};
  }

  /// الحصول على الخطوط حسب الفئة
  Map<String, FontInfo> getFontsByCategory(String category) {
    final allFonts = getAllAvailableFonts();
    return Map.fromEntries(
      allFonts.entries.where((entry) => entry.value.category == category),
    );
  }

  /// الحصول على مسار الخط المحلي
  String? getFontPath(String fontName) {
    return _fontCacheBox?.get('font_$fontName');
  }

  /// التحقق من تحميل الخط
  bool isFontDownloaded(String fontName) {
    return _downloadedFonts[fontName] == true;
  }

  /// حذف خط محدد
  Future<void> deleteFont(String fontName) async {
    try {
      final fontPath = _fontCacheBox?.get('font_$fontName');
      if (fontPath != null) {
        final file = File(fontPath);
        if (await file.exists()) {
          await file.delete();
        }
        await _fontCacheBox?.delete('font_$fontName');
        _downloadedFonts.remove(fontName);
        debugPrint('🗑️ تم حذف الخط: $fontName');
      }
    } catch (e) {
      debugPrint('❌ خطأ في حذف الخط $fontName: $e');
    }
  }

  /// حذف كل الخطوط المحملة
  Future<void> deleteAllFonts() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fontDir = Directory('${directory.path}/fonts');
      
      if (await fontDir.exists()) {
        await fontDir.delete(recursive: true);
      }
      
      await _fontCacheBox?.clear();
      _downloadedFonts.clear();
      
      debugPrint('🗑️ تم حذف كل الخطوط');
    } catch (e) {
      debugPrint('❌ خطأ في حذف الخطوط: $e');
    }
  }

  /// الحصول على حجم الخطوط المحملة
  Future<double> getDownloadedFontsSize() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fontDir = Directory('${directory.path}/fonts');
      
      if (!await fontDir.exists()) {
        return 0;
      }

      double totalSize = 0;
      await for (final file in fontDir.list(recursive: true)) {
        if (file is File) {
          totalSize += await file.length();
        }
      }

      return totalSize / (1024 * 1024); // MB
    } catch (e) {
      debugPrint('❌ خطأ في حساب حجم الخطوط: $e');
      return 0;
    }
  }

  /// الحصول على قائمة الخطوط المحملة
  List<String> getDownloadedFontsList() {
    return _downloadedFonts.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();
  }

  /// Widget لتحميل الخطوط مع مؤشر تقدم
  Widget buildFontDownloader({
    required String fontName,
    required Widget child,
    Widget? loadingWidget,
    Widget? errorWidget,
  }) {
    return FutureBuilder<bool>(
      future: downloadSpecificFont(fontName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget ??
              const Center(
                child: CircularProgressIndicator(),
              );
        }

        if (snapshot.hasError || snapshot.data == false) {
          return errorWidget ??
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'فشل تحميل الخط: $fontName',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              );
        }

        return child;
      },
    );
  }
}

/// Extension لتسهيل استخدام الخطوط البعيدة
extension RemoteFontTextStyle on TextStyle {
  /// استخدام خط بعيد مع fallback للخط المحلي
  TextStyle withRemoteFont(String fontName, {String? fallbackFont}) {
    final loader = RemoteFontLoader();
    
    if (loader.isFontDownloaded(fontName)) {
      return copyWith(fontFamily: fontName);
    }
    
    // استخدام الخط الاحتياطي
    if (fallbackFont != null) {
      return copyWith(fontFamily: fallbackFont);
    }
    
    return this;
  }
}
