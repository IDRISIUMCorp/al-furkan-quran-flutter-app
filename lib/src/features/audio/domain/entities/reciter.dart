/// Reciter Entity — Pure Dart, ZERO Flutter imports
class Reciter {
  final int id;
  final String nameArabic;
  final String nameEnglish;
  final String serverUrl;
  final ReciterStyle style;
  final bool isOfflineAvailable;
  final int downloadedSurahs;

  const Reciter({
    required this.id,
    required this.nameArabic,
    required this.nameEnglish,
    required this.serverUrl,
    required this.style,
    this.isOfflineAvailable = false,
    this.downloadedSurahs = 0,
  });
}

enum ReciterStyle {
  murattal,   // Recitation — measured, melodic
  mujawwad,   // Tajweed — slow, articulated
  muallim,    // Teaching style
  warsh,      // Warsh narration
}
