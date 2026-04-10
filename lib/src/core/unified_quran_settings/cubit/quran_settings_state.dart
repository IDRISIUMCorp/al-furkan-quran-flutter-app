part of 'quran_settings_cubit.dart';

enum QuranTheme {
  oled,
  nightBlue,
  custom,
  graphite,
  midnightPurple,
  sepia,
  cream,
  paperWhite,
  sand,
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

  // Hardcoded getters for removed settings to prevent breaking the rest of the app
  double get pageScale => 1.0;
  bool get enableTafsir => true;
  bool get enableIrab => true;

  const QuranSettingsState({
    this.fontSize = 23.0,
    this.theme = QuranTheme.oled,
    this.highlightColor = Colors.amber,
    this.customBackgroundColor = const Color(0xFF111318),
    this.customTextColor = Colors.white,
    this.showVerseNumbers = true,
    this.showPageInfo = true,
    this.showBasmala = true,
    this.showSurahHeader = true,
    this.tajweedEnabled = false,
    this.isInitialized = false,
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
    );
  }

  bool get isDarkTheme {
    switch (theme) {
      case QuranTheme.oled:
      case QuranTheme.nightBlue:
      case QuranTheme.custom:
      case QuranTheme.graphite:
      case QuranTheme.midnightPurple:
        return true;
      case QuranTheme.sepia:
      case QuranTheme.cream:
      case QuranTheme.paperWhite:
      case QuranTheme.sand:
        return false;
    }
  }

  double get contentScale {
    final fontInfluence = (fontSize - 23.0) / 22.0;
    return (1.0 + fontInfluence).clamp(0.85, 1.4);
  }

  double get verseHeightScale {
    final fontInfluence = (fontSize - 23.0) / 35.0;
    return (1.0 + fontInfluence).clamp(0.9, 1.3);
  }

  // --- Helpers for UI Theme mapping ---

  Color get backgroundColor {
    switch (theme) {
      case QuranTheme.oled:
        return Colors.black;
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
