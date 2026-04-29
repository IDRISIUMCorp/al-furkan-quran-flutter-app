part of 'quran_settings_cubit.dart';

enum QuranTheme {
  oled,
  charcoal,
  nightBlue,
  custom,
  graphite,
  midnightPurple,
  sepia,
  cream,
  paperWhite,
  sand,
}

enum MushafLayoutMode {
  singlePage,
  doublePage,
  continuousScroll,
}

enum QuranFontFamily {
  qpcHafs,
  kfgqpcUthmanicHafs,
  uthmanTahaNaskh,
  alQuranNeo,
  indopakNastaleeq,
  meQuranVolt;

  /// The Flutter font family name as registered in pubspec.yaml
  String get flutterFontFamily => switch (this) {
    QuranFontFamily.qpcHafs => "QPC_Hafs",
    QuranFontFamily.kfgqpcUthmanicHafs => "KFGQPC-Uthmanic-HAFS-Regular",
    QuranFontFamily.uthmanTahaNaskh => "KFGQPC-Uthmanic-HAFS-Regular", // fallback until font added
    QuranFontFamily.alQuranNeo => "AlQuranNeov5x1",
    QuranFontFamily.indopakNastaleeq => "IndopakNastaleeq",
    QuranFontFamily.meQuranVolt => "me_quran_volt_newmet",
  };

  /// Arabic display label
  String get label => switch (this) {
    QuranFontFamily.qpcHafs => "QPC Hafs",
    QuranFontFamily.kfgqpcUthmanicHafs => "KFGQPC عثماني",
    QuranFontFamily.uthmanTahaNaskh => "عثمان طه نسخ",
    QuranFontFamily.alQuranNeo => "Al Quran Neo",
    QuranFontFamily.indopakNastaleeq => "إندوباك نستعليق",
    QuranFontFamily.meQuranVolt => "Me Quran Volt",
  };
}

class QuranSettingsState {
  final double fontSize;
  final QuranTheme theme;
  final Color highlightColor;
  final Color customBackgroundColor;
  final Color customTextColor;
  final bool showVerseNumbers;
  final bool showPageInfo;
  final bool showBasmala;
  final bool showSurahHeader;
  final bool tajweedEnabled;
  final bool isInitialized;
  final List<Color> customBackgroundColors;
  final MushafLayoutMode layoutMode;
  final QuranFontFamily fontFamily;

  // Hardcoded getters for removed settings to prevent breaking the rest of the app
  double get pageScale => 1.0;
  bool get enableTafsir => true;
  bool get enableIrab => true;

  const QuranSettingsState({
    this.fontSize = 23.0,
    this.theme = QuranTheme.charcoal,
    this.highlightColor = Colors.amber,
    this.customBackgroundColor = const Color(0xFF111318),
    this.customTextColor = Colors.white,
    this.showVerseNumbers = true,
    this.showPageInfo = true,
    this.showBasmala = true,
    this.showSurahHeader = true,
    this.tajweedEnabled = false,
    this.isInitialized = false,
    this.customBackgroundColors = const [],
    this.layoutMode = MushafLayoutMode.singlePage,
    this.fontFamily = QuranFontFamily.qpcHafs,
  });

  QuranSettingsState copyWith({
    double? fontSize,
    QuranTheme? theme,
    Color? highlightColor,
    Color? customBackgroundColor,
    Color? customTextColor,
    bool? showVerseNumbers,
    bool? showPageInfo,
    bool? showBasmala,
    bool? showSurahHeader,
    bool? tajweedEnabled,
    bool? isInitialized,
    List<Color>? customBackgroundColors,
    MushafLayoutMode? layoutMode,
    QuranFontFamily? fontFamily,
  }) {
    return QuranSettingsState(
      fontSize: fontSize ?? this.fontSize,
      theme: theme ?? this.theme,
      highlightColor: highlightColor ?? this.highlightColor,
      customBackgroundColor: customBackgroundColor ?? this.customBackgroundColor,
      customTextColor: customTextColor ?? this.customTextColor,
      showVerseNumbers: showVerseNumbers ?? this.showVerseNumbers,
      showPageInfo: showPageInfo ?? this.showPageInfo,
      showBasmala: showBasmala ?? this.showBasmala,
      showSurahHeader: showSurahHeader ?? this.showSurahHeader,
      tajweedEnabled: tajweedEnabled ?? this.tajweedEnabled,
      isInitialized: isInitialized ?? this.isInitialized,
      customBackgroundColors: customBackgroundColors ?? this.customBackgroundColors,
      layoutMode: layoutMode ?? this.layoutMode,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }

  bool get isDarkTheme {
    switch (theme) {
      case QuranTheme.oled:
      case QuranTheme.charcoal:
      case QuranTheme.nightBlue:
      case QuranTheme.graphite:
      case QuranTheme.midnightPurple:
        return true;
      case QuranTheme.custom:
        return customBackgroundColor.computeLuminance() < 0.5;
      case QuranTheme.sepia:
      case QuranTheme.cream:
      case QuranTheme.paperWhite:
      case QuranTheme.sand:
        return false;
    }
  }

  // contentScale is kept at 1.0 — the QCF glyph rendering system
  // handles its own scaling via baselineWidth and fontSize parameters.
  // Overriding this caused the mushaf to become oversized and misaligned.
  double get contentScale => 1.0;

  double get verseHeightScale => 1.0;

  /// Responsive overlay scale — page info (juz, surah, hizb, page number)
  /// font sizes are multiplied by this factor so they stay proportional
  /// to the mushaf content at any font size.
  double get overlayScale => 1.0;

  // --- Helpers for UI Theme mapping ---

  Color get backgroundColor {
    switch (theme) {
      case QuranTheme.oled:
        return Colors.black;
      case QuranTheme.charcoal:
        return const Color(0xFF212529);
      case QuranTheme.nightBlue:
        return const Color(0xFF0F172A); // Slate 900
      case QuranTheme.custom:
        return customBackgroundColor;
      case QuranTheme.graphite:
        return const Color(0xFF121417);
      case QuranTheme.midnightPurple:
        return const Color(0xFF140B2D);
      case QuranTheme.sepia:
        return const Color(0xFFF4ECD8);
      case QuranTheme.cream:
        return const Color(0xFFFFFDD0);
      case QuranTheme.paperWhite:
        return Colors.white;
      case QuranTheme.sand:
        return const Color(0xFFF3E7D3);
    }
  }

  Color get textColor {
    switch (theme) {
      case QuranTheme.oled:
      case QuranTheme.charcoal:
      case QuranTheme.nightBlue:
      case QuranTheme.graphite:
      case QuranTheme.midnightPurple:
        return Colors.white;
      case QuranTheme.sepia:
      case QuranTheme.cream:
      case QuranTheme.paperWhite:
      case QuranTheme.sand:
        return Colors.black87;
      case QuranTheme.custom:
        return customTextColor;
    }
  }
}
