import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:qcf_quran/qcf_quran.dart';
import 'package:al_furkan/src/screen/settings/widgets/premium_widget_design.dart';
import 'package:al_furkan/src/screen/settings/widgets/zekr_mini_widget_design.dart';
import 'package:al_furkan/src/screen/settings/widgets/prayer_widget_design.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:intl/intl.dart';

@pragma('vm:entry-point')
void ayahWidgetCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      if (!Hive.isBoxOpen("user")) {
        final dir = await getApplicationDocumentsDirectory();
        Hive.init(dir.path);
        await Hive.openBox("user");
      }
      await AyahOfTheDayService.updateWidget(forceRefresh: true);
    } catch (e) {
      debugPrint("Background AyahWidget Update Failed: $e");
    }
    return Future.value(true);
  });
}

class AyahOfTheDayService {
  static const String appGroupId = 'com.idrisium.alfurkan';
  static const String androidWidgetName = 'AyahWidgetProvider';
  static const String periodicTaskName = "updateAyahWidgetTask";

  static const Map<String, List<String>> _categoryAyahs = {
    "sabr": ["2:153", "2:155", "3:200", "8:46", "39:10", "11:115", "16:127", "40:55", "76:24", "20:130"],
    "rahmah": ["39:53", "7:156", "2:163", "6:12", "6:54", "40:7", "17:24", "23:109", "12:87", "21:107"],
    "jannah": ["2:25", "3:133", "18:31", "39:73", "47:15", "56:15", "76:12", "88:8", "9:72", "32:17"],
    "dua": ["2:201", "2:286", "3:8", "3:193", "14:40", "20:25", "25:74", "40:60", "23:118", "27:19"],
    "tawbah": ["66:8", "24:31", "20:82", "39:53", "4:17", "9:104", "42:25", "3:135", "5:39", "25:70"],
  };

  static String formatAyahTextForWidget(String rawText) {
    final stripped = rawText.replaceAll(RegExp(r"<[^>]+>"), "");
    return _preventOrphanFirstWord(stripped);
  }

  static String buildWidgetSurahName(int surah, int verse) {
    return "سورة ${getSurahNameArabic(surah)} - آية ${_toArabicDigits(verse.toString())}";
  }

  static Future<Map<String, String>?> _getRandomZekr({String? category}) async {
    try {
      final jsonString = await rootBundle.loadString('assets/wahy/json/azkar.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> azkarList = data['data'] as List<dynamic>;
      
      List<dynamic> filteredAzkar = azkarList;
      if (category != null && category != 'random') {
        final categoryMap = {
          'morning': 'أذكار الصباح',
          'evening': 'أذكار المساء',
          'sleep': 'أذكار النوم',
          'wakeup': 'أذكار الاستيقاظ من النوم',
          'prayer': 'أذكار الصلاة',
        };
        final categoryName = categoryMap[category] ?? category;
        filteredAzkar = azkarList.where((z) => z['category'] == categoryName).toList();
      }
      
      if (filteredAzkar.isEmpty) return null;
      final randomZekr = filteredAzkar[Random().nextInt(filteredAzkar.length)];
      
      return {
        'text': randomZekr['zekr'] as String,
        'reference': '${randomZekr['category']} - ${randomZekr['description'] ?? ''}',
        'count': randomZekr['count'] as String? ?? '1',
      };
    } catch (e) {
      debugPrint("Error fetching random zekr: $e");
      return null;
    }
  }

  static Future<void> setupBackgroundUpdates() async {
    await Workmanager().initialize(
      ayahWidgetCallbackDispatcher,
      isInDebugMode: false,
    );
    final box = Hive.box("user");
    final frequencyMinutes = box.get("widget_update_frequency_minutes", defaultValue: 15) as int;

    // Minimum allowed by Android is 15 minutes
    final safeFrequency = frequencyMinutes < 15 ? 15 : frequencyMinutes;

    await Workmanager().registerPeriodicTask(
      "ayahWidgetUpdate",
      periodicTaskName,
      frequency: Duration(minutes: safeFrequency),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    );
  }

  static Future<Map<String, dynamic>> _calculatePrayerTimes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locString = prefs.getString("user_location");
      
      if (locString == null) return {};

      final locJson = json.decode(locString);
      final lat = locJson["latitude"] as double?;
      final lng = locJson["longitude"] as double?;
      
      if (lat == null || lng == null) return {};

      final coordinates = Coordinates(lat, lng);
      
      // Egyptian default
      final params = CalculationParameters(
        fajrAngle: 19.5,
        ishaAngle: 17.5,
        method: CalculationMethod.egyptian,
      );
      
      final date = DateTime.now();
      PrayerTimes prayerTimes = PrayerTimes(
        coordinates: coordinates, 
        date: date, 
        calculationParameters: params, 
        precision: true
      );
      
      String formatTime(DateTime? time) {
        if (time == null) return "٠٠:٠٠";
        final f = DateFormat('hh:mm a', 'en'); // en layout so we can format AM/PM manually 
        String raw = f.format(time);
        raw = raw.replaceAll("AM", "ص").replaceAll("PM", "م");
        return _toArabicDigits(raw);
      }

      final prayerNames = {
        Prayer.fajr: "الفجر",
        Prayer.sunrise: "الشروق",
        Prayer.dhuhr: "الظهر",
        Prayer.asr: "العصر",
        Prayer.maghrib: "المغرب",
        Prayer.isha: "العشاء",
      };

      Map<String, String> formattedTimes = {
        "الفجر": formatTime(prayerTimes.fajr),
        "الشروق": formatTime(prayerTimes.sunrise),
        "الظهر": formatTime(prayerTimes.dhuhr),
        "العصر": formatTime(prayerTimes.asr),
        "المغرب": formatTime(prayerTimes.maghrib),
        "العشاء": formatTime(prayerTimes.isha),
      };

      final next = prayerTimes.nextPrayer(date: date);
      String nextPrayerStr = prayerNames[next] ?? "الفجر";
      
      if (date.isAfter(prayerTimes.isha)) {
        // If all prayers passed, next is Fajr tomorrow
        final tomorrow = date.add(const Duration(days: 1));
        final tomorrowTimes = PrayerTimes(
          coordinates: coordinates, 
          date: tomorrow, 
          calculationParameters: params, 
          precision: true
        );
        formattedTimes["الفجر"] = formatTime(tomorrowTimes.fajr); 
        nextPrayerStr = "الفجر";
      }

      return {
        "times": formattedTimes,
        "next": nextPrayerStr,
      };

    } catch (e) {
      debugPrint("Failed to load or parse location for adhan: $e");
      return {};
    }
  }

  static Future<void> updateWidget({bool forceRefresh = false}) async {
    await HomeWidget.setAppGroupId(appGroupId);
    final box = Hive.box("user");
    
    final contentType = box.get("widget_content_type", defaultValue: "quran") as String;
    final widgetTheme = box.get("widget_theme", defaultValue: "midnight_ocean") as String;
    final widgetFontFamily = box.get("widget_font_family", defaultValue: "") as String;
    final String widgetPrayerMode = box.get("widget_prayer_mode", defaultValue: "all") as String;
    
    final customSurah = box.get("widget_custom_surah") as int?;
    final customVerse = box.get("widget_custom_verse") as int?;
    final frequencyMinutes = box.get("widget_update_frequency_minutes", defaultValue: 1440) as int;
    final lastTimeStr = box.get("widget_last_update_time") as String?;
    final lastTime = lastTimeStr != null ? DateTime.tryParse(lastTimeStr) : null;

    int? surah, verse;
    bool shouldGenerateNew = false;

    // Only generate new ayah if explicitly forced OR if timer expired
    if (forceRefresh) {
      shouldGenerateNew = true;
    } else if (lastTime != null && DateTime.now().difference(lastTime).inMinutes >= frequencyMinutes) {
      shouldGenerateNew = true;
    }

    // Custom ayah always takes priority - never generate new
    if (customSurah != null && customVerse != null) {
      shouldGenerateNew = false;
      surah = customSurah;
      verse = customVerse;
    }

    // If not generating new, try to get existing ayah from widget data
    if (!shouldGenerateNew && surah == null) {
      final existingKey = await HomeWidget.getWidgetData<String>('ayah_key');
      if (existingKey != null && existingKey.contains(':')) {
        final parts = existingKey.split(':');
        surah = int.tryParse(parts[0]);
        verse = int.tryParse(parts[1]);
      }
    }

    String contentText = "";
    String contentReference = "";
    
    if (contentType == "azkar") {
      final azkarCategory = box.get("widget_azkar_category", defaultValue: "random") as String;
      final zekrData = await _getRandomZekr(category: azkarCategory);
      if (zekrData != null) {
        contentText = zekrData['text']!;
        final count = zekrData['count']!;
        contentReference = count != "1" 
            ? "${zekrData['reference']!} (${_toArabicDigits(count)} مرات)"
            : zekrData['reference']!;
      } else {
        contentText = "سبحان الله وبحمده، سبحان الله العظيم";
        contentReference = "ذكر عشوائي";
      }
    } else {
      if (surah == null || verse == null) {
        final category = box.get("widget_ayah_category", defaultValue: "random") as String;
        if (category != "random" && _categoryAyahs.containsKey(category)) {
          final list = _categoryAyahs[category]!;
          final parts = list[Random().nextInt(list.length)].split(":");
          surah = int.tryParse(parts[0]);
          verse = int.tryParse(parts[1]);
        } else {
          surah = Random().nextInt(114) + 1;
          verse = Random().nextInt(getVerseCount(surah)) + 1;
        }
        box.put("widget_last_update_time", DateTime.now().toIso8601String());
      }
      contentText = formatAyahTextForWidget(getVerse(surah!, verse!, verseEndSymbol: false));
      contentReference = buildWidgetSurahName(surah, verse);
    }

    await HomeWidget.saveWidgetData<String>('ayah_key', "$surah:$verse");
    
    // Setup Deep Links
    if (contentType == "azkar") {
      await HomeWidget.saveWidgetData<String>('ayah_url', 'alfurkan://widget?action=open_azkar');
      await HomeWidget.saveWidgetData<String>('word_url', 'alfurkan://widget?action=open_azkar');
    } else {
      await HomeWidget.saveWidgetData<String>('ayah_url', 'alfurkan://widget?action=jump_to_ayah&surah=$surah&verse=$verse');
      await HomeWidget.saveWidgetData<String>('word_url', 'alfurkan://widget?action=jump_to_ayah&surah=$surah&verse=$verse');
    }
    await HomeWidget.saveWidgetData<String>('prayer_url', 'alfurkan://widget?action=open_prayer');
    
    // حساب مواقيت الصلاة لو مفعلة
    Map<String, String>? prayerTimes;
    String? nextPrayerName;
    
    if (widgetPrayerMode != "none") {
      final map = await _calculatePrayerTimes();
      if (map.isNotEmpty) {
        prayerTimes = map["times"] as Map<String, String>;
        nextPrayerName = map["next"] as String;
      }
    }

    final String selectedContentType = box.get("widget_content_type", defaultValue: "quran");
    final bool isDarkTheme = widgetTheme.contains("dark") || widgetTheme == "midnight_ocean" || widgetTheme == "graphite_glass";
    final double fontSizeMultiplier = box.get("widget_font_size", defaultValue: 1.0) as double;

    debugPrint("Background Fetch: Rendering widget images and executing...");

    // 1. Ayah / Zekr Widget
    try {
      final widgetPreview = PremiumWidgetDesign(
        ayahText: contentText,
        surahName: contentReference,
        themeId: widgetTheme,
        fontFamily: widgetFontFamily,
        contentType: selectedContentType,
        fontSizeMultiplier: fontSizeMultiplier,
      );

      await HomeWidget.renderFlutterWidget(
        widgetPreview,
        logicalSize: PremiumWidgetDesign.canvasSize,
        pixelRatio: 2.2,
        key: 'ayah_image',
      );
    } catch (e) {
      debugPrint("Error rendering PremiumWidgetDesign to image: $e");
    }

    // 2. Prayer Only Widget
    try {
      final prayerPreview = PrayerWidgetDesign(
        themeId: widgetTheme,
        prayerDisplayMode: widgetPrayerMode,
        prayerTimes: prayerTimes,
        nextPrayerName: nextPrayerName,
        isDark: isDarkTheme,
      );

      await HomeWidget.renderFlutterWidget(
        prayerPreview,
        logicalSize: PrayerWidgetDesign.canvasSize,
        pixelRatio: 2.2,
        key: 'prayer_image',
      );
    } catch (e) {
      debugPrint("Error rendering PrayerWidgetDesign to image: $e");
    }

    // 3. Mini Zekr Lock Screen Widget
    try {
      final miniPreview = ZekrMiniWidgetDesign(
        zekrText: contentText,
        reference: contentReference,
        fontFamily: widgetFontFamily,
        themeId: widgetTheme,
        isDark: isDarkTheme,
        fontSizeMultiplier: fontSizeMultiplier,
      );
      
      await HomeWidget.renderFlutterWidget(
        miniPreview,
        logicalSize: ZekrMiniWidgetDesign.canvasSize,
        pixelRatio: 2.2,
        key: 'word_image',
      );
    } catch (e) {
      debugPrint("Error rendering ZekrMiniWidgetDesign to image: $e");
    }

    await HomeWidget.updateWidget(
      name: androidWidgetName,
      androidName: androidWidgetName,
    );
    
    await HomeWidget.updateWidget(
      name: 'WordWidgetProvider',
      androidName: 'WordWidgetProvider',
    );

    await HomeWidget.updateWidget(
      name: 'PrayerWidgetProvider',
      androidName: 'PrayerWidgetProvider',
    );
  }

  static String _preventOrphanFirstWord(String text) {
    if (text.isEmpty) return text;
    final firstSpaceIndex = text.indexOf(' ');
    if (firstSpaceIndex != -1 && firstSpaceIndex <= 10) {
      return text.replaceFirst(' ', '\u00A0');
    }
    return text;
  }

  static String _toArabicDigits(String number) {
    const arabics = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    final buffer = StringBuffer();
    for (final ch in number.split('')) {
      final digit = int.tryParse(ch);
      if (digit == null) {
        buffer.write(ch);
      } else {
        buffer.write(arabics[digit]);
      }
    }
    return buffer.toString();
  }
}
