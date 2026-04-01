import 'dart:math';
import 'package:home_widget/home_widget.dart';
import 'package:qcf_quran/qcf_quran.dart';
import 'package:al_quran_v3/src/screen/settings/widgets/ayah_widget_design.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'package:path_provider/path_provider.dart';

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

  static const Map<String, List<String>> _categoryAyahs = {
    "sabr": [
      "2:153",
      "2:155",
      "3:200",
      "8:46",
      "39:10",
      "11:115",
      "16:127",
      "40:55",
      "76:24",
      "20:130",
    ],
    "rahmah": [
      "39:53",
      "7:156",
      "2:163",
      "6:12",
      "6:54",
      "40:7",
      "17:24",
      "23:109",
      "12:87",
      "21:107",
    ],
    "jannah": [
      "2:25",
      "3:133",
      "18:31",
      "39:73",
      "47:15",
      "56:15",
      "76:12",
      "88:8",
      "9:72",
      "32:17",
    ],
    "dua": [
      "2:201",
      "2:286",
      "3:8",
      "3:193",
      "14:40",
      "20:25",
      "25:74",
      "40:60",
      "23:118",
      "27:19",
    ],
    "tawbah": [
      "66:8",
      "24:31",
      "20:82",
      "39:53",
      "4:17",
      "9:104",
      "42:25",
      "3:135",
      "5:39",
      "25:70",
    ],
  };

  static const Map<String, String> categoryLabels = {
    "random": "عشوائي",
    "sabr": "الصبر",
    "rahmah": "الرحمة",
    "jannah": "الجنة",
    "dua": "الدعاء",
    "tawbah": "التوبة",
  };

  static const String periodicTaskName = "updateAyahWidgetTask";

  static Color resolveWidgetPrimaryColor(Box box) {
    final int primaryColorInt =
        box.get("primaryColor", defaultValue: 0xFF33B18E) as int;
    return Color(primaryColorInt);
  }

  static String formatAyahTextForWidget(String rawText) {
    final stripped = rawText.replaceAll(RegExp(r"<[^>]+>"), "");
    return _preventOrphanFirstWord(stripped);
  }

  static String buildWidgetSurahName(int surah, int verse) {
    return "سورة ${getSurahNameArabic(surah)} - آية ${_toArabicDigits(verse.toString())}";
  }

  static Future<void> setupBackgroundUpdates() async {
    await Workmanager().initialize(
      ayahWidgetCallbackDispatcher,
      isInDebugMode: false,
    );
    final box = Hive.box("user");
    final frequencyMinutes =
        box.get("widget_update_frequency_minutes", defaultValue: 1440) as int;

    await Workmanager().registerPeriodicTask(
      "ayahWidgetUpdate",
      periodicTaskName,
      frequency: Duration(minutes: frequencyMinutes),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    );
  }

  static Future<void> updateWidget({bool forceRefresh = false}) async {
    await HomeWidget.setAppGroupId(appGroupId);
    final box = Hive.box("user");
    final customSurah = box.get("widget_custom_surah") as int?;
    final customVerse = box.get("widget_custom_verse") as int?;
    final widgetFontSize =
        box.get("widget_font_size", defaultValue: 45.0) as double;
    final widgetTheme =
        box.get("widget_theme", defaultValue: "glass_dark") as String;

    final customBgColorInt = box.get("widget_custom_bg_color") as int?;
    final customBgColorInt2 = box.get("widget_custom_bg_color2") as int?;
    final isGradientBg =
        box.get("widget_is_gradient_bg", defaultValue: false) as bool;
    final customTextColorInt = box.get("widget_custom_text_color") as int?;
    final customSurahColorInt = box.get("widget_custom_surah_color") as int?;

    final customBgColor = customBgColorInt != null
        ? Color(customBgColorInt)
        : null;
    final customBgColor2 = customBgColorInt2 != null
        ? Color(customBgColorInt2)
        : null;
    final customTextColor = customTextColorInt != null
        ? Color(customTextColorInt)
        : null;
    final customSurahColor = customSurahColorInt != null
        ? Color(customSurahColorInt)
        : null;

    final Color primaryColor = resolveWidgetPrimaryColor(box);

    final frequencyMinutes =
        box.get("widget_update_frequency_minutes", defaultValue: 1440) as int;
    final lastTimeStr = box.get("widget_last_update_time") as String?;
    final lastTime = lastTimeStr != null
        ? DateTime.tryParse(lastTimeStr)
        : null;

    int? surah;
    int? verse;

    bool shouldGenerateNew = forceRefresh;
    if (!forceRefresh && lastTime != null) {
      if (DateTime.now().difference(lastTime).inMinutes >= frequencyMinutes) {
        shouldGenerateNew = true;
      }
    } else if (lastTime == null) {
      shouldGenerateNew = true;
    }

    bool hasCustomAyahSelected = customSurah != null && customVerse != null;
    if (hasCustomAyahSelected) {
      shouldGenerateNew = false;
      surah = customSurah;
      verse = customVerse;
    }

    if (!shouldGenerateNew) {
      final existingKey = await HomeWidget.getWidgetData<String>('ayah_key');
      if (existingKey != null && existingKey.contains(':')) {
        final parts = existingKey.split(':');
        surah = int.tryParse(parts[0]);
        verse = int.tryParse(parts[1]);
      }
    }

    if (surah == null || verse == null) {
      final category =
          box.get("widget_ayah_category", defaultValue: "random") as String;
      if (category != "random" && _categoryAyahs.containsKey(category)) {
        final list = _categoryAyahs[category]!;
        final r = Random().nextInt(list.length);
        final parts = list[r].split(":");
        surah = int.tryParse(parts[0]);
        verse = int.tryParse(parts[1]);
      } else {
        surah = Random().nextInt(114) + 1;
        verse = Random().nextInt(getVerseCount(surah)) + 1;
      }
      box.put("widget_last_update_time", DateTime.now().toIso8601String());
    }

    final String ayahText = formatAyahTextForWidget(
      getVerse(surah!, verse!, verseEndSymbol: false),
    );

    final formattedSurahName = buildWidgetSurahName(surah, verse);

    // Save key to HomeWidget for deep linking
    final ayahKey = "$surah:$verse";
    await HomeWidget.saveWidgetData<String>('ayah_key', ayahKey);

    // Save actual text for settings preview
    await HomeWidget.saveWidgetData<String>('ayah_text', ayahText);
    await HomeWidget.saveWidgetData<String>('surah_name', formattedSurahName);

    // Render exact UI to image and save path in 'ayah_image'
    try {
      final widgetPreview = AyahWidgetDesign(
        ayahText: ayahText,
        surahName: formattedSurahName,
        primaryColor: primaryColor,
        fontSize: widgetFontSize,
        themeId: widgetTheme,
        fontFamily:
            box.get(
                  "widget_font_family",
                  defaultValue: "KFGQPC-Uthmanic-HAFS-Regular",
                )
                as String,
        ayahNumber: verse,
        customBgColor: customBgColor,
        customBgColor2: customBgColor2,
        isGradientBg: isGradientBg,
        customTextColor: customTextColor,
        customSurahColor: customSurahColor,
      );

      await HomeWidget.renderFlutterWidget(
        widgetPreview,
        logicalSize: const Size(800, 400),
        key: 'ayah_image',
      );
    } catch (e) {
      debugPrint("Error rendering flutter widget to image: $e");
    }

    // Trigger update
    await HomeWidget.updateWidget(
      name: androidWidgetName,
      androidName: androidWidgetName,
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
