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
  final double pageScale;
  final QuranTheme theme;
  final bool tajweedEnabled;
  final Color highlightColor;
  final bool enableTafsir;
  final bool enableIrab;
  final bool showVerseNumbers;
  final bool showPageInfo;
  final bool showBasmala;
  final bool showSurahHeader;
  final bool isInitialized;

  const QuranSettingsState({
    this.fontSize = 23.0,
    this.pageScale = 1.0,
    this.theme = QuranTheme.oled,
    this.tajweedEnabled = true,
    this.highlightColor = Colors.amber,
    this.enableTafsir = true,
    this.enableIrab = false,
    this.showVerseNumbers = true,
    this.showPageInfo = true,
    this.showBasmala = true,
    this.showSurahHeader = true,
    this.isInitialized = false,
  });

  QuranSettingsState copyWith({
    double? fontSize,
    double? pageScale,
    QuranTheme? theme,
    bool? tajweedEnabled,
    Color? highlightColor,
    bool? enableTafsir,
    bool? enableIrab,
    bool? showVerseNumbers,
    bool? showPageInfo,
    bool? showBasmala,
    bool? showSurahHeader,
    bool? isInitialized,
  }) {
    return QuranSettingsState(
      fontSize: fontSize ?? this.fontSize,
      pageScale: pageScale ?? this.pageScale,
      theme: theme ?? this.theme,
      tajweedEnabled: tajweedEnabled ?? this.tajweedEnabled,
      highlightColor: highlightColor ?? this.highlightColor,
      enableTafsir: enableTafsir ?? this.enableTafsir,
      enableIrab: enableIrab ?? this.enableIrab,
      showVerseNumbers: showVerseNumbers ?? this.showVerseNumbers,
      showPageInfo: showPageInfo ?? this.showPageInfo,
      showBasmala: showBasmala ?? this.showBasmala,
      showSurahHeader: showSurahHeader ?? this.showSurahHeader,
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
    final fontInfluence = (fontSize - 23.0) / 140.0;
    final pageInfluence = (pageScale - 1.0) * 0.85;
    return (1.0 + fontInfluence + pageInfluence).clamp(0.92, 1.16);
  }

  double get verseHeightScale {
    final fontInfluence = (fontSize - 23.0) / 220.0;
    final pageInfluence = (pageScale - 1.0) * 0.35;
    return (1.0 + fontInfluence + pageInfluence).clamp(0.95, 1.10);
  }

  // --- Helpers for UI Theme mapping ---

  Color get backgroundColor {
    switch (theme) {
      case QuranTheme.oled:
        return Colors.black;
      case QuranTheme.nightBlue:
        return const Color(0xFF0F172A); // Slate 900
      case QuranTheme.custom:
        return Colors.black; // Fallback, could be expanded
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
        return Colors.white;
    }
  }
}
