/// App Fonts Constants
/// Centralized font family names for consistent typography
library;

class AppFonts {
  AppFonts._();

  // Quran Fonts
  static const String qpcHafs = 'QPC_Hafs';
  static const String alQuranNeo = 'AlQuranNeov5x1';
  static const String indopakNastaleeq = 'IndopakNastaleeq';
  static const String uthmanicHafs = 'KFGQPC-Uthmanic-HAFS-Regular';
  static const String surahName = 'surah-name-v1';

  // App Fonts
  static const String notoSans = 'NotoSans';

  // Default Fonts
  static const String defaultQuranFont = uthmanicHafs;
  static const String defaultAppFont = notoSans;

  // Available Quran Fonts List
  static const List<String> quranFonts = [
    qpcHafs,
    alQuranNeo,
    indopakNastaleeq,
    uthmanicHafs,
  ];

  // Available App Fonts List
  static const List<String> appFonts = [
    notoSans,
  ];

  // Custom imported fonts (runtime)
  static List<String> customFonts = [];
  static List<String> customFontNames = [];
}
